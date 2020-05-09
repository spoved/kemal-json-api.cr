require "../adapter"

class SpecAdapter::Mongo < KemalJsonApi::Adapter::Mongo
  # Returns the mongodb instance host or ip
  property host : String = "localhost"
  # Returns the mongodb instance port
  property port : Int32 = 27017

  def initialize(@host : String, @port : Int32, @database_name : String)
  end

  # Returns the mongo client
  def get_client : ::Mongo::Client
    ::Mongo::Client.new(self.uri)
  end

  # Returns the requested database
  def database(database : String) : ::Mongo::Database
    client = get_client
    client[database]
  end

  # Returns the requested collection
  def collection(collection : String, db : ::Mongo::Database? = nil) : ::Mongo::Collection
    db = database(self.database_name) if db.nil?
    db[collection]
  end

  # Returns the mongodb connection URI
  def uri : String
    "mongodb://#{host}:#{port}/#{database_name}"
  end

  def with_database(&block : ::Mongo::Database -> Nil) : Nil
    db = database(self.database_name)
    yield db
  end

  def with_collection(collection : String, &block : ::Mongo::Collection -> Nil) : Nil
    with_database do |db|
      col = self.collection(collection, db)
      yield col
    end
  end
end

def adapter : SpecAdapter::Mongo
  SpecAdapter::Mongo.new("localhost", 27017, "test")
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

def get_characters(id : String)
  headers = HTTP::Headers.new
  headers["Accept"] = "application/vnd.api+json"
  get "/characters/#{id}", headers
  response.body.should_not be_nil
  JSON.parse(response.body)
end

def delete_characters(id : String)
  headers = HTTP::Headers.new
  headers["Accept"] = "application/vnd.api+json"
  delete "/characters/#{id}", headers
  response.status_code
end

def post_characters(data : Hash(String, String))
  headers = HTTP::Headers.new
  headers["Content-Type"] = "application/vnd.api+json"
  headers["Accept"] = "application/vnd.api+json"

  payload = %Q({
    "data": {
      "type": "characters",
      "attributes": #{data.to_json}
    }
  })

  post "/characters", headers, payload
  response.body.should_not be_nil
  JSON.parse(response.body)
end

def patch_characters(id : String, data : Hash(String, String))
  headers = HTTP::Headers.new
  headers["Content-Type"] = "application/vnd.api+json"
  headers["Accept"] = "application/vnd.api+json"

  payload = %Q({
    "data": {
      "type": "characters",
      "id": "#{id}",
      "attributes": #{data.to_json}
    }
  })

  patch "/characters/#{id}", headers, payload
  response.body.should_not be_nil
  JSON.parse(response.body)
end

# :nodoc:
class TestResource < KemalJsonApi::Resource
  def create(data : Hash(String, JSON::Any)) : String | Nil
    "550e8400-e29b-41d4-a716-446655440000"
  end

  def read(id : Int | String) : KemalJsonApi::Resource::Data
    {
      type:       "articles",
      id:         "1",
      attributes: {
        "title" => JSON::Any.new("JSON API paints my bikeshed!"),
      },
      relationships: {
        "author" => JSON.parse({
          "links" => {
            "related" => "http://example.com/articles/1/author",
          },
        }.to_json),
      },
    }
  end

  def read_relation(id : Int | String, relation : String) : Identifier | Nil
    nil
  end

  def list_relations(id : Int | String, relation : String) : Array(Identifier)
    [] of Identifier
  end

  def update(id : Int | String, args : Hash(String, JSON::Any)) : KemalJsonApi::Resource::Data
    {
      type:       "articles",
      id:         "1",
      attributes: {
        "title" => JSON::Any.new("JSON API paints my bikeshed!"),
      },
      relationships: {
        "author" => JSON.parse({
          "links" => {
            "related" => "http://example.com/articles/1/author",
          },
        }.to_json),
      },
    }
  end

  def delete(id : Int | String) : Bool
    true
  end

  def list : Array(KemalJsonApi::Resource::Data)
    [{
      type:       "articles",
      id:         "1",
      attributes: {
        "title" => JSON::Any.new("JSON API paints my bikeshed!"),
      },
      relationships: {
        "author" => JSON.parse({
          "links" => {
            "related" => "http://example.com/articles/1/author",
          },
        }.to_json),
      },
    },
    {
      type:       "articles",
      id:         "2",
      attributes: {
        "title" => JSON::Any.new("Rails is Omakase"),
      },
      relationships: {} of String => JSON::Any,
    }] of KemalJsonApi::Resource::Data | Nil
  end

  def read_relation_identifier(id : Int | String, relation : String) : Identifier | Nil
    nil
  end

  def list_relation_identifiers(id : Int | String, relation : String) : Array(Identifier)
    [] of KemalJsonApi::Resource::Identifier
  end

  def read_relation_object(env : HTTP::Server::Context, path_info : PathInfo) : KemalJsonApi::Resource::Data
    nil
  end

  def list_relation_object(env : HTTP::Server::Context, path_info : PathInfo) : Array(KemalJsonApi::Resource::Data)
    [] of KemalJsonApi::Resource::Data
  end
end
