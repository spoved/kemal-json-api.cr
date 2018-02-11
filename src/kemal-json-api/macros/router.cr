require "../../kemal-json-api"

# Macro to assist in creating {KemalJsonApi::Resources}
macro json_api_resource(name, adapter)
  KemalJsonApi::Router.add KemalJsonApi::Resource::Mongo.new({{adapter}}, singular: {{name}})
end
