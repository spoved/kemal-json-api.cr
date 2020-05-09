require "kemal"
require "./resource"

module KemalJsonApi
  class Handler < Kemal::Handler
    private macro fixed_only(paths, method = "GET")
      class_name = {{@type.name}}
      method_downcase = {{method}}.downcase
      class_name_method = "#{class_name}/#{method_downcase}"
      ({{paths}}).each do |path|
        @@only_routes_tree.add class_name_method + path, '/' + method_downcase + path
      end
    end

    def add_only(path : String, method : String = "GET")
      fixed_only [path], method
    end

    def call(env)
      # continue on to next handler unless the request matches the only filter
      return call_next(env) unless only_match?(env)

      if (env.request.headers.has_key?("Accept") &&
         env.request.headers["Accept"] == "application/vnd.api+json")
        env.response.content_type = "application/vnd.api+json"
        # puts "updating header"
        call_next(env)
      else
        # TODO: Return a 415 error
        call_next(env)
      end
    end
  end
end
