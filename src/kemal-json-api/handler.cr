require "kemal"
require "./resource"

module KemalJsonApi
  class Handler < Kemal::Handler
    def add_only(path : String, method : String = "GET")
      only [path], method
    end

    def call(env)
      # continue on to next handler unless the request matches the only filter
      return call_next(env) unless only_match?(env)

      if (env.request.headers.has_key?("Accept") &&
         env.request.headers["Accept"] == "application/vnd.api+json")
        puts "setting content header"
        env.response.content_type = "application/vnd.api+json"
      else
        puts "Bad content type"
        puts env
      end

      return call_next(env)
    end
  end
end
