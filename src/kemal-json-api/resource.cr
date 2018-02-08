require "../ext/string"
require "./action"

module KemalJsonApi
  # Abstract class to represent a JSON API resource object
  # See http://jsonapi.org/format/#document-resource-objects for proper format
  #  of the returns
  abstract class Resource
    @actions = [] of Action
    @singular : String
    @plural : String
    @prefix : String

    alias ActionsList = Hash(ActionMethod, ActionType)

    def initialize(*args, actions : ActionsList = ALL_ACTIONS, plural : String = "", prefix : String = "", singular : String = "")
      @singular = singular.empty? ? self.class.to_s.underscore : singular.underscore
      @plural = plural.empty? ? @singular.pluralize : plural.underscore
      @prefix = prefix.underscore
      setup_actions! actions
    end

    getter :actions, :singular, :prefix, :plural

    # Returns the singular name of the resource
    # ```
    # model.singular # => "trait"
    # ```
    def singular : String
      @singular
    end

    # Returns the plural name of the resource
    # ```
    # model.plural # => "traits"
    # ```
    def plural : String
      @plural
    end

    # Returns the prefix string of the resource
    # ```
    # model.prefix # => "model_"
    # ```
    def prefix : String
      @prefix
    end

    # Returns the collection name. Which is made up of prefix string and the
    #  singular name of the resource
    # ```
    # model.prefix     # => "model_"
    # model.singular   # => "trait"
    # model.collection # => "model_trait"
    # ```
    def collection : String
      "#{@prefix}#{@singular}"
    end

    def prepare_params(env : HTTP::Server::Context) : Hash(String, JSON::Type)
      begin
        data = Hash(String, JSON::Type).new
        body = env.request.body
        if body
          string = body.gets_to_end
          data = JSON.parse(string).as_h
        else
          # TODO: Render error
        end
        data
      rescue
        Hash(String, JSON::Type).new
      end
    end

    # Should return a {String} contianing the id of the record created
    # ```
    # model.create({"data" => "data"}) # => "550e8400-e29b-41d4-a716-446655440000"
    # ```
    abstract def create(data : JSON::Type) : String | Nil

    # Should return a {Hash(String, JSON::Type)} object that contains the
    #  record the {id} provided
    # ```
    # {
    #   "type":       "articles",
    #   "id":         "1",
    #   "attributes": {
    #     "title": "JSON API paints my bikeshed!",
    #   },
    #   "relationships": {
    #     "author": {
    #       "links": {
    #         "related": "http://example.com/articles/1/author",
    #       },
    #     },
    #   },
    # }
    # ```
    abstract def read(id : Int | String) : JSON::Type | Nil

    # Should return an updated {Hash(String, JSON::Type)} object that contains the
    #  record and id that was updated
    # ```
    # {
    #   "type":       "articles",
    #   "id":         "1",
    #   "attributes": {
    #     "title": "JSON API paints my bikeshed!",
    #   },
    #   "relationships": {
    #     "author": {
    #       "links": {
    #         "related": "http://example.com/articles/1/author",
    #       },
    #     },
    #   },
    # }
    # ```
    abstract def update(id : Int | String, args : JSON::Type) : JSON::Type | Nil

    # Will return true/false indicating if the record was deleted
    # ```
    # Model.new.delete(1) # => true
    # ```
    abstract def delete(id : Int | String) : Bool

    # Will return an array of JSON API resource objects
    # ```
    # [{
    #   "type":       "articles",
    #   "id":         "1",
    #   "attributes": {
    #     "title": "JSON API paints my bikeshed!",
    #   },
    # }, {
    #   "type":       "articles",
    #   "id":         "2",
    #   "attributes": {
    #     "title": "Rails is Omakase",
    #   },
    # }]
    # ```
    abstract def list : Array(JSON::Type)

    protected def setup_actions!(actions = {} of Action::Method => Action::MethodType)
      if !actions || actions.empty?
        @actions.push Action.new(ActionMethod::CREATE, ActionType::POST)
        @actions.push Action.new(ActionMethod::READ, ActionType::GET)
        @actions.push Action.new(ActionMethod::UPDATE, ActionType::PUT)
        @actions.push Action.new(ActionMethod::DELETE, ActionType::DELETE)
        @actions.push Action.new(ActionMethod::LIST, ActionType::GET)
      else
        actions.each do |k, v|
          @actions.push Action.new(k, v)
        end
      end
    end
  end
end
