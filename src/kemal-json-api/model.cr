require "../ext/string"

module KemalJsonApi
  # Abstract class to represent a JSON API resource object
  # See http://jsonapi.org/format/#document-resource-objects for proper format
  #  of the return
  abstract class Model
    def initialize(*args, @plural : String = "", @prefix : String = "", @singular : String = "")
      @singular = singular.empty? ? self.class.to_s.underscore : singular.underscore
      @plural = plural.empty? ? @singular.pluralize : plural.underscore
      @prefix = prefix.underscore
    end

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
  end
end
