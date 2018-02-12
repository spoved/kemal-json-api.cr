require "../../kemal-json-api"

# Macro to assist in creating `KemalJsonApi::Resource` instances
macro json_api_resource(name, adapter, relations = [] of KemalJsonApi::Relation)
  KemalJsonApi::Router.add KemalJsonApi::Resource::Mongo.new({{adapter}}, singular: {{name}}, relations: {{relations}})
end
