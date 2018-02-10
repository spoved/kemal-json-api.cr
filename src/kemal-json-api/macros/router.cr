require "../../kemal-json-api"

# Macro to assist in creating {KemalJsonApi::Resources}
macro json_api_resource(name, adapter)
  class ::{{name.camelcase.id}} < KemalJsonApi::Resource::Mongo
  end

  KemalJsonApi::Router.add {{name.camelcase.id}}.new({{adapter}})
end
