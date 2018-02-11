def adapter : KemalJsonApi::Adapter::Mongo
  KemalJsonApi::Adapter::Mongo.new("localhost", 27017, "test")
end

def mongo_resource_character : KemalJsonApi::Resource::Mongo
  KemalJsonApi::Resource::Mongo.new(adapter, singular: "character")
end

def get_characters
  headers = HTTP::Headers.new
  headers["Accept"] = "application/vnd.api+json"
  get "/characters"
  response.body.should_not be_nil
  JSON.parse(response.body)
end

def get_characters_5a7f723025ae0bfae26b43d1
  headers = HTTP::Headers.new
  headers["Accept"] = "application/vnd.api+json"
  get "/characters/5a7f723025ae0bfae26b43d1", headers
  response.body.should_not be_nil
  JSON.parse(response.body)
end

# :nodoc:
class TestResource < KemalJsonApi::Resource
  def create(data : JSON::Type) : String | Nil
    "550e8400-e29b-41d4-a716-446655440000"
  end

  def read(id : Int | String) : JSON::Type | Nil
    JSON.parse({
      "type":       "articles",
      "id":         "1",
      "attributes": {
        "title": "JSON API paints my bikeshed!",
      },
      "relationships": {
        "author": {
          "links": {
            "related": "http://example.com/articles/1/author",
          },
        },
      },
    }.to_json).as_h
  end

  def update(id : Int | String, args : JSON::Type) : JSON::Type | Nil
    JSON.parse({
      "type":       "articles",
      "id":         "1",
      "attributes": {
        "title": "JSON API paints my bikeshed!",
      },
      "relationships": {
        "author": {
          "links": {
            "related": "http://example.com/articles/1/author",
          },
        },
      },
    }.to_json).as_h
  end

  def delete(id : Int | String) : Bool | Nil
    true
  end

  def list : Array(JSON::Type)
    JSON.parse([{
      "type":       "articles",
      "id":         "1",
      "attributes": {
        "title": "JSON API paints my bikeshed!",
      },
    }, {
      "type":       "articles",
      "id":         "2",
      "attributes": {
        "title": "Rails is Omakase",
      },
    }].to_json).as_a
  end
end
