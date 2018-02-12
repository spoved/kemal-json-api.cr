require "mongo"
require "kemal"
require "../src/kemal-json-api/macros/router"
mongodb = KemalJsonApi::Adapter::Mongo.new("localhost", 27017, "test")

module WebApp
  json_api_resource "actor", mongodb, [KemalJsonApi::Relation.new(KemalJsonApi::RelationType::HAS_MANY, "trait")]
  json_api_resource "trait", mongodb, [KemalJsonApi::Relation.new(KemalJsonApi::RelationType::BELONGS_TO, "actor")]
  KemalJsonApi::Router.generate_routes!
  Kemal.run
end
