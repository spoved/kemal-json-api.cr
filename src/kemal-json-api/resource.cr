require "../ext/string"
require "./action"
require "./adapter"
require "./relation"
require "./resource/identifier"

module KemalJsonApi
  # alias KemalJsonApi::Resource::Data = NamedTuple( type: String, id: String, attributes: JSON::Any::Type, relationships: JSON::Any::Type ) | Nil

  # Abstract class to represent a JSON API resource object
  # See http://jsonapi.org/format/#document-resource-objects for proper format
  #  of the returns
  abstract class Resource
    alias Data = NamedTuple(
      type: String,
      id: String,
      attributes: Hash(String, JSON::Any),
      relationships: Hash(String, JSON::Any)) | Nil

    @actions = [] of Action
    @singular : String
    @plural : String
    @prefix : String
    @adapter : KemalJsonApi::Adapter
    @relations = [] of KemalJsonApi::Relation

    alias ActionsList = Hash(ActionMethod, ActionType)

    def initialize(@adapter : KemalJsonApi::Adapter, *args,
                   actions : ActionsList = ALL_ACTIONS,
                   plural : String = "",
                   prefix : String = "",
                   singular : String = "",
                   @relations : Array(KemalJsonApi::Relation) = [] of KemalJsonApi::Relation)
      @singular = singular.empty? ? self.class.name.underscore : singular.underscore
      @plural = plural.empty? ? @singular.pluralize : plural.underscore
      @prefix = prefix.underscore
      setup_actions! actions
    end

    getter :actions, :singular, :prefix, :plural, :adapter, :relations

    # Returns the singular name of the resource
    #
    # ```
    # resource.singular # => "trait"
    # ```
    def singular : String
      @singular
    end

    # Returns the plural name of the resource
    #
    # ```
    # resource.plural # => "traits"
    # ```
    def plural : String
      @plural
    end

    # Returns the prefix string of the resource
    #
    # ```
    # resource.prefix # => "model_"
    # ```
    def prefix : String
      @prefix
    end

    # Returns the collection name. Which is made up of prefix string and the
    #  singular name of the resource
    #
    # ```
    # resource.prefix     # => "model_"
    # resource.singular   # => "trait"
    # resource.collection # => "model_trait"
    # ```
    def collection : String
      "#{@prefix}#{@singular}"
    end

    # Returns `String` of the resource base path, which equals the plural of the
    #  resource or appended by the prefix if present
    #
    # Without prefix:
    #
    # ```
    # resource.prefix    # => ""
    # resource.singular  # => "trait"
    # resource.base_path # => "trait"
    # ```
    #
    # With prefix:
    #
    # ```
    # resource.prefix    # => "model"
    # resource.singular  # => "trait"
    # resource.base_path # => "model/trait"
    # ```
    def base_path : String
      if prefix.empty?
        plural
      else
        prefix + '/' + plural
      end
    end

    # Should return a `String` contianing the id of the record created
    #
    # ```
    # model.create({"data" => "data"}) # => "550e8400-e29b-41d4-a716-446655440000"
    # ```
    abstract def create(data : Hash(String, JSON::Any)) : String | Nil

    # Should return a `Hash(String, JSON::Any::Type)` object that contains the
    #  record the id provided
    #
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
    abstract def read(id : Int | String) : KemalJsonApi::Resource::Data

    # Should return an updated `Hash(String, JSON::Type)` object that contains the
    #  record and id that was updated
    #
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
    abstract def update(id : Int | String, args : Hash(String, JSON::Any)) : KemalJsonApi::Resource::Data

    # Will return true/false indicating if the record was deleted
    #
    # ```
    # Model.new.delete(1) # => true
    # ```
    abstract def delete(id : Int | String) : Bool

    # Will return an array of JSON API resource objects
    #
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
    abstract def list : Array(KemalJsonApi::Resource::Data)

    #####################
    # Relation functions
    #####################

    # Will return a Resource Identifier Object for a to-one relationship
    #
    # ```
    # {
    #   "type": "people",
    #   "id":   "12",
    # }
    # ```
    abstract def read_relation_identifier(id : Int | String, relation : String) : Identifier | Nil

    # Return an array listing resource's to-many relationship of Resource
    #   Identifier Objects
    # http://jsonapi.org/format/#document-resource-identifier-objects
    #
    # With records
    #
    # ```
    # [
    #   {"type": "tags", "id": "2"},
    #   {"type": "tags", "id": "3"},
    # ]
    # ```
    #
    # Without records
    #
    # ```
    # []
    # ```
    abstract def list_relation_identifiers(id : Int | String, relation : String) : Array(Identifier)

    # TODO: Complete this
    abstract def read_relation_object(env : HTTP::Server::Context, path_info : PathInfo) : KemalJsonApi::Resource::Data

    # TODO: Complete this
    abstract def list_relation_object(env : HTTP::Server::Context, path_info : PathInfo) : Array(KemalJsonApi::Resource::Data)

    # Will parse the paramaters provided in the `HTTP::Server::Context#request`
    def prepare_params(env : HTTP::Server::Context) : Hash(String, JSON::Any)
      begin
        data = Hash(String, JSON::Any).new
        body = env.request.body

        if body
          string = body.gets_to_end
          data = JSON.parse(string).as_h
        else
          # TODO: Render error
        end
        data
      rescue ex
        Hash(String, JSON::Any).new
      end
    end

    # Will set up action associations for the resource
    protected def setup_actions!(actions = {} of Action::Method => Action::MethodType)
      if !actions || actions.empty?
        @actions.push Action.new(ActionMethod::CREATE, ActionType::POST)
        @actions.push Action.new(ActionMethod::READ, ActionType::GET)
        @actions.push Action.new(ActionMethod::UPDATE, ActionType::PATCH)
        @actions.push Action.new(ActionMethod::DELETE, ActionType::DELETE)
        @actions.push Action.new(ActionMethod::LIST, ActionType::GET)
      else
        actions.each do |k, v|
          @actions.push Action.new(k, v)
        end
      end
    end

    # Will generate the relationship object for the provided id and relation
    # http://jsonapi.org/format/#document-resource-object-relationships
    private def gen_relation_object(id : String, relation : KemalJsonApi::Relation) : Hash(String, JSON::Any)
      {
        "self" => JSON::Any.new("/#{base_path}/#{id}/relationships/#{relation.name}"),
      }
    end
  end
end
