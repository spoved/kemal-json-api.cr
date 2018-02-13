require "mongo"
require "kemal"
require "../src/kemal-json-api/macros/router"
mongodb = KemalJsonApi::Adapter::Mongo.new("localhost", 27017, "test")

client = Mongo::Client.new("mongodb://localhost:27017/test")
db = client["test"]
db.drop
collection = db["character"]
collection.insert({
  "_id"    => BSON::ObjectId.new("5a7f723025ae0bfae26b43d1"),
  "name"   => "James Bond",
  "age"    => 37,
  "traits" => ["5a7f723025ae0bfae26b43a1"],
})
collection.insert({"_id" => BSON::ObjectId.new("5a7f723025ae0bfae26b43d2"), "name" => "Rand", "age" => 31})

db["trait"].insert({
  "_id"          => BSON::ObjectId.new("5a7f723025ae0bfae26b43a1"),
  "name"         => "hair_color",
  "value"        => "black",
  "character_id" => "5a7f723025ae0bfae26b43d1",
})

module WebApp
  json_api_resource "character", mongodb, [KemalJsonApi::Relation.new(KemalJsonApi::RelationType::HAS_MANY, "trait")]
  json_api_resource "trait", mongodb, [KemalJsonApi::Relation.new(KemalJsonApi::RelationType::BELONGS_TO, "character")]
  KemalJsonApi::Router.generate_routes!
  Kemal.run
end
