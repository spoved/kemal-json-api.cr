require "spec"
require "json"
require "spec-kemal"
require "../src/kemal-json-api"
require "./factories"

def clear_resources
  KemalJsonApi::Router.resources = Array(KemalJsonApi::Resource).new
end

client = Mongo::Client.new("mongodb://localhost:27017/test")
db = client["test"]

Spec.before_each do
  clear_resources
  db.drop
  collection = db["character"]
  collection.insert({"_id" => BSON::ObjectId.new("5a7f723025ae0bfae26b43d1"), "name" => "James Bond", "age" => 37})
  collection.insert({"_id" => BSON::ObjectId.new("5a7f723025ae0bfae26b43d2"), "name" => "Rand", "age" => 31})
end

Spec.after_each do
  clear_resources
  db.drop
end
