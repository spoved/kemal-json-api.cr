require "../resource"

module KemalJsonApi
  class Resource::Mongo < KemalJsonApi::Model
    # Should return a {String} contianing the id of the record created
    # ```
    # model.create({"data" => "data"}) # => "550e8400-e29b-41d4-a716-446655440000"
    # ```
    def create(data : JSON::Type) : String | Nil
      ret = nil
      @mongodb.with_collection(collection) do |coll|
        doc = data.to_bson
        doc["_id"] = BSON::ObjectId.new
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
      @mongodb.with_collection(collection) do |coll|
        record = coll.find_one({"_id" => BSON::ObjectId.new(id)})
        _gen_resource_object(record)
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
    def update(id : Int | String, args : JSON::Type) : JSON::Type | Nil
      ret = 0
      @mongodb.with_collection(collection) do |coll|
        coll.update({"_id" => BSON::ObjectId.new(id)}, {"$set" => data})
        if (err = coll.last_error)
          ret = err["nModified"].as(Int)
        end
      end
      ret
    end

    # Deletes the record identified by the provided id.
    #   Will return true/false indicating if the record was deleted
    # ```
    # Model.new.delete(1) # => true
    # ```
    def delete(id : Int | String) : Bool
      ret = false
      @mongodb.with_collection(collection) do |coll|
        doc = coll.find_one({"_id" => BSON::ObjectId.new(id)})
        if doc
          #  TODO: remove find_one to use only remove?
          coll.remove({"_id" => BSON::ObjectId.new(id)})
          ret = true
        end
      end
      ret
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
      @mongodb.with_collection(collection) do |coll|
        coll.find(BSON.new) do |doc|
          results << _gen_resource_object(doc)
        end
      end
      results
    end

    def _gen_resource_object(doc : BSON) : JSON::Type
      {
        "type":          plural,
        "id":            doc["_id"],
        "attributes":    _gen_attributes(doc),
        "relationships": {},
      }
    end

    def _gen_attributes(hash : BSON) : JSON::Type | Nil
      json = JSON.parse(hash.to_json).as_h
      json.delete_if { |key, value| key =~ /^(id|_id)$/ }
      json
    end

  end
end
