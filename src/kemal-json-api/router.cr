require "kemal"

module KemalJsonApi
  class Router
    @@resources = [] of KemalJsonApi::Resource
    @@handler = KemalJsonApi::Handler.new
    class_property :resources
    class_getter :handler

    alias PathInfo = NamedTuple(
      resource: KemalJsonApi::Resource,
      path: String,
      block: Proc(HTTP::Server::Context, PathInfo, String),
      action: KemalJsonApi::Action)

    # Will append the resource to the router list
    def self.add(resource : KemalJsonApi::Resource)
      @@resources.push resource
    end

    def self.generate_routes!
      resources.each do |resource|
        resource.actions.each do |action|
          path_info = create_path(resource, action)
          create_route(path_info) unless path_info[:path].empty?
        end
      end
    end

    private def self.create_path(resource : KemalJsonApi::Resource, action : KemalJsonApi::Action) : PathInfo
      case action.method
      when ActionMethod::CREATE
        {
          resource: resource,
          path:     "/#{resource.base_path}",
          block:    ->create(HTTP::Server::Context, PathInfo),
          action:   action,
        }
      when ActionMethod::READ
        {
          resource: resource,
          path:     "/#{resource.base_path}/:id",
          block:    ->read(HTTP::Server::Context, PathInfo),
          action:   action,
        }
      when ActionMethod::UPDATE
        {
          resource: resource,
          path:     "/#{resource.base_path}/:id",
          block:    ->update(HTTP::Server::Context, PathInfo),
          action:   action,
        }
      when ActionMethod::DELETE
        {
          resource: resource,
          path:     "/#{resource.base_path}/:id",
          block:    ->delete(HTTP::Server::Context, PathInfo),
          action:   action,
        }
      when ActionMethod::LIST
        {
          resource: resource,
          path:     "/#{resource.base_path}",
          block:    ->list(HTTP::Server::Context, PathInfo),
          action:   action,
        }
      else
        {
          resource: resource,
          path:     "",
          block:    ->(env : HTTP::Server::Context, path_info : PathInfo) { "" },
          action:   action,
        }
      end
    end

    private def self.create_route(path_info : PathInfo)
      case path_info[:action].type
      when ActionType::GET
        handler.add_only(path_info[:path], "GET")
        get "#{path_info[:path]}" do |env|
          begin
            path_info[:block].call env, path_info
          rescue ex : Exception
            {"status": "error", "message": ex.message}.to_json
          end
        end
      when ActionType::POST
        handler.add_only(path_info[:path], "POST")
        post "#{path_info[:path]}" do |env|
          begin
            path_info[:block].call env, path_info
          rescue ex : Exception
            {"status": "error", "message": ex.message}.to_json
          end
        end
      when ActionType::PUT
        handler.add_only(path_info[:path], "PUT")
        put "#{path_info[:path]}" do |env|
          begin
            path_info[:block].call env, path_info
          rescue ex : Exception
            {"status": "error", "message": ex.message}.to_json
          end
        end
      when ActionType::PATCH
        handler.add_only(path_info[:path], "PATCH")
        patch "#{path_info[:path]}" do |env|
          begin
            path_info[:block].call env, path_info
          rescue ex : Exception
            {"status": "error", "message": ex.message}.to_json
          end
        end
      when ActionType::DELETE
        handler.add_only(path_info[:path], "DELETE")
        delete "#{path_info[:path]}" do |env|
          begin
            path_info[:block].call env, path_info
          rescue ex : Exception
            {"status": "error", "message": ex.message}.to_json
          end
        end
      end
      puts "#{path_info[:action].type} #{path_info[:path]}" if DEBUG
    end

    private def self.update(env : HTTP::Server::Context, path_info : PathInfo) : String
      id = env.params.url["id"]
      # TODO: let pass only valid fields
      ret = path_info[:resource].update(id, path_info[:resource].prepare_params(env))
      env.response.content_type = "application/vnd.api+json"
      env.response.headers["Connection"] = "close"
      if ret.nil?
        env.response.status_code = 404
        {"status": "error", "message": "not_found"}.to_json
      elsif ret == 0
        env.response.status_code = 400
        {"status": "error", "message": "bad_request"}.to_json
      else
        env.response.status_code = 200
        {"status": "ok"}.to_json
      end
    end

    private def self.delete(env : HTTP::Server::Context, path_info : PathInfo) : String
      id = env.params.url["id"]
      ret = path_info[:resource].delete id
      env.response.status_code = ret ? 200 : 404
      env.response.content_type = "application/vnd.api+json"
      env.response.headers["Connection"] = "close"
      if ret
        env.response.status_code = 200
        {"status": "ok"}.to_json
      else
        env.response.status_code = 404
        {"status": "error", "message": "not_found"}.to_json
      end
    end

    private def self.list(env : HTTP::Server::Context, path_info : PathInfo) : String
      ret = path_info[:resource].list
      env.response.status_code = 200
      env.response.content_type = "application/vnd.api+json"
      env.response.headers["Connection"] = "close"

      {
        links: {
          self: "/#{path_info[:resource].plural}",
        },
        data: ret,
      }.to_json
    end

    private def self.read(env : HTTP::Server::Context, path_info : PathInfo) : String
      id = env.params.url["id"]
      ret = path_info[:resource].read id
      env.response.status_code = ret ? 200 : 404
      env.response.content_type = "application/vnd.api+json"
      env.response.headers["Connection"] = "close"
      {
        links: {
          self: "/#{path_info[:resource].plural}/#{id}",
        },
        data: ret,
      }.to_json
    end

    private def self.create(env : HTTP::Server::Context, path_info : PathInfo) : String
      # TODO: let pass only valid fields
      # puts env.inspect
      data = path_info[:resource].prepare_params(env)
      if data.has_key?("data") && data["data"].as(Hash(String, JSON::Type)).has_key?("type")
        args = data["data"].as(Hash(String, JSON::Type))
        id = path_info[:resource].create args["attributes"].as(Hash(String, JSON::Type))

        id ? {
          links: {
            self: "/#{path_info[:resource].plural}/#{id}",
          },
          data: path_info[:resource].read(id),
        }.to_json : ""
      else
        ret = ""
      end

      env.response.content_type = "application/vnd.api+json"
      env.response.headers["Connection"] = "close"
      if ret && !ret.nil?
        env.response.status_code = 201
        ret
      else
        env.response.status_code = 400
        {"status": "error", "message": "bad_request"}.to_json
      end
    end
  end
end
