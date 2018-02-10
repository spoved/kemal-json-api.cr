require "spec"
require "json"
require "../src/kemal-json-api"
require "./factories"

def clear_resources
  KemalJsonApi::Router.resources = Array(KemalJsonApi::Resource).new
end
