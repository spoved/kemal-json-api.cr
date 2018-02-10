require "../resource"

module KemalJsonApi
  class Resource::Mongo < KemalJsonApi::Resource
    # Should return a {String} contianing the id of the record created
    # ```
    # model.create({"data" => "data"}) # => "550e8400-e29b-41d4-a716-446655440000"
    # ```
    def create(data : JSON::Type) : String | Nil
      ret = nil
      adapter.with_collection(collection) do |coll|
        doc = data.to_bson
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

    # Should return a {Hash(String, JSON::Type)} object that contains the
    #  associated record to the {id} provided
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
    def read(id : Int | String) : JSON::Type | Nil
      adapter.with_collection(collection) do |coll|
        record = coll.find_one({"_id" => BSON::ObjectId.new(id)})
        return _gen_resource_object(record) if record
      end
    end

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
    def update(id : Int | String, args : JSON::Type) : Bool
      adapter.with_collection(collection) do |coll|
        coll.update({"_id" => BSON::ObjectId.new(id)}, {"$set" => args})
        if (err = coll.last_error)
          return err["nModified"] == 1 ? true : false
        else
          return false
        end
      end
    end

    # Deletes the record identified by the provided id.
    #   Will return true/false indicating if the record was deleted
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
    end

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
    def list : Array(JSON::Type)
      results = [] of JSON::Type
      adapter.with_collection(collection) do |coll|
        coll.find(BSON.new) do |doc|
          results << _gen_resource_object(doc)
        end
      end
      results
    end

    # Should return a {Hash(String, JSON::Type)} object that contains the
    #  translated associated {BSON} object
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
    def _gen_resource_object(doc : BSON) : JSON::Type
      Hash(String, JSON::Type){
        "type"          => plural,
        "id"            => doc["_id"].to_s.chomp('\u0000'),
        "attributes"    => _gen_attributes(doc),
        "relationships" => {} of String => JSON::Type,
      }
    end

    # Should return a {Hash(String, JSON::Type)} object that contains the
    #  attributes of the object. Will strip the id or _id field
    # ```
    # {
    #   "title": "JSON API paints my bikeshed!",
    # }
    # ```
    def _gen_attributes(hash : BSON) : JSON::Type | Nil
      json = JSON.parse(hash.to_json).as_h
      json.delete_if { |key, value| key =~ /^(id|_id)$/ }
      json
    end
  end
end
