require "kemal"
require "uuid"
require "./ext/string"
require "./kemal-json-api/*"
require "./kemal-json-api/adapters/*"
require "./kemal-json-api/resources/*"

module KemalJsonApi
  DEBUG = false

  ALL_ACTIONS = {} of ActionMethod => ActionType

  error 400 do |env|
    env.response.content_type = "application/vnd.api+json"
    {
      "id":     UUID.random.to_s,
      "status": "400",
      "title":  "bad_request",
    }.to_json
  end

  error 401 do |env|
    env.response.content_type = "application/vnd.api+json"
    {
      "id":     UUID.random.to_s,
      "status": "401",
      "title":  "not_authorized",
    }.to_json
  end

  error 404 do |env|
    env.response.content_type = "application/vnd.api+json"
    {
      "id":     UUID.random.to_s,
      "status": "404",
      "title":  "not_found",
    }.to_json
  end

  error 415 do |env|
    env.response.content_type = "application/vnd.api+json"
    {
      "id":     UUID.random.to_s,
      "status": "415",
      "title":  "unsupported_media_type",
      "detail": "Need to supply Accept: application/vnd.api+json headers",
    }.to_json
  end

  error 500 do |env|
    env.response.content_type = "application/vnd.api+json"
    {
      "id":     UUID.random.to_s,
      "status": "500",
      "detail": "internal_server_error",
    }.to_json
  end
end
