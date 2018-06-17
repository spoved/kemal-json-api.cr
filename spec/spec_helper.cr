require "spec"
require "json"
require "spec-kemal"
require "../src/kemal-json-api"
require "./factories"

ENV["KEMAL_ENV"] = "test"

def clear_resources
  KemalJsonApi::Router.resources = Array(KemalJsonApi::Resource).new
end

client = Mongo::Client.new("mongodb://localhost:27017/test")
db = client["test"]

Spec.before_each do
  clear_resources
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
    "name"         => "value",
    "character_id" => "5a7f723025ae0bfae26b43d1",
  })
end

Spec.after_each do
  clear_resources
  db.drop
end
