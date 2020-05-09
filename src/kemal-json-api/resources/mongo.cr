require "mongo"
require "../resource"
require "../adapters/mongo"

module KemalJsonApi
  class Resource::Mongo < KemalJsonApi::Resource
    # Should return a `String` contianing the id of the record created
    #
    # ```
    # model.create({"data" => "data"}) # => "550e8400-e29b-41d4-a716-446655440000"
    # ```
    def create(data : Hash(String, JSON::Any)) : String | Nil
      create(data.to_bson)
    end

    def create(doc : BSON) : String | Nil
      ret = nil
      adapter.with_collection(collection) do |coll|
        if doc.has_key?("id")
          doc["_id"] = BSON::ObjectId.new(doc["id"].to_s)
          doc["id"] = nil
        else
          doc["_id"] = BSON::ObjectId.new
        end

        coll.insert(doc)
        if (err = coll.last_error)
          return doc["_id"].to_s.chomp('\u0000')
        end
      end
      ret
    end

    # Should return a `Hash(String, JSON::Type)` object that contains the
    #  associated record to the id provided
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
    def read(id : Int | String) : KemalJsonApi::Resource::Data
      adapter.with_collection(collection) do |coll|
        record = coll.find_one({"_id" => BSON::ObjectId.new(id)})
        return _gen_resource_object(record) if record
      end
    end

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
    def update(id : Int | String, args : Hash(String, JSON::Any)) : KemalJsonApi::Resource::Data
      adapter.with_collection(collection) do |coll|
        coll.update({"_id" => BSON::ObjectId.new(id)}, {"$set" => args})
        if (err = coll.last_error)
          return err["nModified"] == 1 ? read(id) : nil
        else
          return nil
        end
      end
    end

    # Deletes the record identified by the provided id.
    #   Will return true/false indicating if the record was deleted
    #
    # ```
    # Model.new.delete(1) # => true
    # ```
    def delete(id : Int | String) : Bool
      adapter.with_collection(collection) do |coll|
        coll.remove({"_id" => BSON::ObjectId.new(id)})
        if (err = coll.last_error)
          return err["nRemoved"] == 1 ? true : false
        else
          return false
        end
      end
      false
    end

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
    def list : Array(KemalJsonApi::Resource::Data)
      results = [] of KemalJsonApi::Resource::Data
      adapter.with_collection(collection) do |coll|
        coll.find(BSON.new) do |doc|
          results << _gen_resource_object(doc)
        end
      end
      results
    end

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
    def read_relation_identifier(id : Int | String, relation : String) : KemalJsonApi::Resource::Identifier | Nil
      adapter.with_collection(collection) do |coll|
        record = coll.find_one({"_id" => BSON::ObjectId.new(id)})
        if record && record["#{relation}_id"]
          return KemalJsonApi::Resource::Identifier.new(relation, record["#{relation}_id"].to_s)
        end
      end
      nil
    end

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
    def list_relation_identifiers(id : Int | String, relation : String) : Array(KemalJsonApi::Resource::Identifier)
      results = [] of KemalJsonApi::Resource::Identifier
      adapter.with_collection(collection) do |coll|
        doc = coll.find_one({"_id" => BSON::ObjectId.new(id)})
        next unless doc
        record = _gen_attributes(doc)

        if record && record[relation] && record[relation].is_a? Array(JSON::Any)
          record[relation].as(Array(JSON::Any)).each do |rel_id|
            results << KemalJsonApi::Resource::Identifier.new(relation, rel_id.to_s)
          end
        end
      end
      results
    end

    # TODO: Complete this
    private def read_relation_object(env : HTTP::Server::Context, path_info : PathInfo) : KemalJsonApi::Resource::Data
      nil
    end

    # TODO: Complete this
    private def list_relation_object(env : HTTP::Server::Context, path_info : PathInfo) : Array(KemalJsonApi::Resource::Data)
      [] of KemalJsonApi::Resource::Data
    end

    # Should return a `Hash(String, JSON::Type)` object that contains the
    #  translated associated `BSON` object
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
    protected def _gen_resource_object(doc : BSON) : KemalJsonApi::Resource::Data
      id = doc["_id"].to_s.chomp('\u0000')
      {
        type:          plural,
        id:            id,
        attributes:    _gen_attributes(doc),
        relationships: _gen_relationships(id, doc),
      }
    end

    # Should return a `Hash(String, JSON::Type)` object that contains the
    #  attributes of the object. Will strip the id or _id field
    #
    # ```
    # {
    #   "title": "JSON API paints my bikeshed!",
    # }
    # ```
    protected def _gen_attributes(hash : BSON) : JSON::Any::Type
      json = JSON.parse(hash.to_json).as_h
      json.delete_if { |key, value| key =~ /^(id|_id)$/ }
      _strip_relation(json)
      json
    end

    # Will strip the provided hash of any relationship keys
    protected def _strip_relation(json : Hash(String, ::JSON::Any)) : Nil
      if !self.relations.empty?
        self.relations.each do |rel|
          case rel.type
          when KemalJsonApi::RelationType::BELONGS_TO
            json.delete_if { |key, value| key =~ /^#{rel.name}_id$/ }
          when KemalJsonApi::RelationType::HAS_ONE
            json.delete_if { |key, value| key =~ /^#{rel.name}_id$/ }
          when KemalJsonApi::RelationType::HAS_MANY
            json.delete_if { |key, value| key =~ /^#{rel.name}$/ }
          when KemalJsonApi::RelationType::HAS_AND_BELONGS_TO_MANY
            json.delete_if { |key, value| key =~ /^#{rel.name}$/ }
          end
        end
      end
      nil
    end

    # Should return a `Hash(String, JSON::Type)` object that contains the
    #  relationships of the object
    #
    # ```
    # {
    #   "author": {
    #     "links": {
    #       "self":    "/articles/1/relationships/author",
    #       "related": "/articles/1/author",
    #     },
    #     "data": {"type": "people", "id": "9"},
    #   },
    # }
    # ```
    protected def _gen_relationships(id : String, hash : BSON) : JSON::Any::Type
      if relations.empty?
        {} of String => JSON::Any
      else
        rels = {} of String => JSON::Any
        relations.each do |rel|
          rels[rel.name] = JSON::Any.new(gen_relation_object(id, rel))
        end
        rels
      end
    end
  end
end
