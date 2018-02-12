require "kemal"

module KemalJsonApi
  class Router
    @@resources = [] of KemalJsonApi::Resource
    @@handler = KemalJsonApi::Handler.new
    class_property :resources
    class_getter :handler

    # A `NamedTuple` containing all information needed to generate a kemal route
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

    # Will create a `PathInfo` containing all information needed to generate
    #  kemal routes
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

    # Will create kemal route based on the `PathInfo`
    private def self.create_route(path_info : PathInfo)
      case path_info[:action].type
      when ActionType::GET
        handler.add_only(path_info[:path], "GET")
        get "#{path_info[:path]}" do |env|
          begin
            path_info[:block].call env, path_info
          rescue ex : Exception
            error env, 0, ex.message.to_s
          end
        end
      when ActionType::POST
        handler.add_only(path_info[:path], "POST")
        post "#{path_info[:path]}" do |env|
          begin
            path_info[:block].call env, path_info
          rescue ex : Exception
            error env, 0, ex.message.to_s
          end
        end
      when ActionType::PUT
        handler.add_only(path_info[:path], "PUT")
        put "#{path_info[:path]}" do |env|
          begin
            path_info[:block].call env, path_info
          rescue ex : Exception
            error env, 0, ex.message.to_s
          end
        end
      when ActionType::PATCH
        handler.add_only(path_info[:path], "PATCH")
        patch "#{path_info[:path]}" do |env|
          begin
            path_info[:block].call env, path_info
          rescue ex : Exception
            error env, 0, ex.message.to_s
          end
        end
      when ActionType::DELETE
        handler.add_only(path_info[:path], "DELETE")
        delete "#{path_info[:path]}" do |env|
          begin
            path_info[:block].call env, path_info
          rescue ex : Exception
            error env, 0, ex.message.to_s
          end
        end
      end
      puts "#{path_info[:action].type} #{path_info[:path]}" if DEBUG
    end

    # Proc to handle updating resources
    private def self.update(env : HTTP::Server::Context, path_info : PathInfo) : String
      id = env.params.url["id"]
      updated = false
      data = path_info[:resource].prepare_params(env)
      if data.has_key?("data") && data["data"].as(Hash(String, JSON::Type)).has_key?("type")
        args = data["data"].as(Hash(String, JSON::Type))
        updated = path_info[:resource].update id, args["attributes"].as(Hash(String, JSON::Type))
      end

      env.response.content_type = "application/vnd.api+json"
      env.response.headers["Connection"] = "close"
      if updated
        env.response.status_code = 200
        {
          links: {
            self: "/#{path_info[:resource].plural}/#{id}",
          },
          data: path_info[:resource].read(id),
        }.to_json
      else
        error env, 400
      end
    end

    # Proc to handle deleting resources
    private def self.delete(env : HTTP::Server::Context, path_info : PathInfo) : String
      id = env.params.url["id"]
      ret = path_info[:resource].delete id
      env.response.status_code = ret ? 200 : 404
      env.response.content_type = "application/vnd.api+json"
      env.response.headers["Connection"] = "close"
      if ret
        env.response.status_code = 200
        ""
      else
        error env, 404
      end
    end

    # Proc to handle listing resources
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

    # Proc to handle reading a sindle resource
    private def self.read(env : HTTP::Server::Context, path_info : PathInfo) : String
      id = env.params.url["id"]
      ret = path_info[:resource].read id
      if ret
        env.response.status_code = 200
        env.response.content_type = "application/vnd.api+json"
        env.response.headers["Connection"] = "close"
        {
          links: {
            self: "/#{path_info[:resource].plural}/#{id}",
          },
          data: ret,
        }.to_json
      else
        error env, 404
      end
    end

    # Proc to handle create resources
    private def self.create(env : HTTP::Server::Context, path_info : PathInfo) : String
      # TODO: let pass only valid fields
      data = path_info[:resource].prepare_params(env)
      if data.has_key?("data") && data["data"].as(Hash(String, JSON::Type)).has_key?("type")
        args = data["data"].as(Hash(String, JSON::Type))
        id = path_info[:resource].create args["attributes"].as(Hash(String, JSON::Type))
      end

      env.response.content_type = "application/vnd.api+json"
      env.response.headers["Connection"] = "close"
      if id && !id.nil?
        env.response.status_code = 201
        {
          links: {
            self: "/#{path_info[:resource].plural}/#{id}",
          },
          data: path_info[:resource].read(id),
        }.to_json
      else
        error env, 400
      end
    end

    # Will set `HTTP::Server::Context` status_code and content_type, will return
    #  error json stringbased on passed code
    private def self.error(env : HTTP::Server::Context, code : Int32, msg : String = "") : String
      env.response.status_code = code
      env.response.content_type = "application/vnd.api+json"
      case code
      when 400
        env.response.content_type = "application/vnd.api+json"
        {
          "id":     UUID.random.to_s,
          "status": "400",
          "title":  "bad_request",
        }.to_json
      when 401
        env.response.content_type = "application/vnd.api+json"
        {
          "id":     UUID.random.to_s,
          "status": "401",
          "title":  "not_authorized",
        }.to_json
      when 404
        env.response.content_type = "application/vnd.api+json"
        {
          "id":     UUID.random.to_s,
          "status": "404",
          "title":  "not_found",
        }.to_json
      when 415
        env.response.content_type = "application/vnd.api+json"
        {
          "id":     UUID.random.to_s,
          "status": "415",
          "title":  "unsupported_media_type",
          "detail": "Need to supply Accept: application/vnd.api+json headers",
        }.to_json
      when 500
        env.response.content_type = "application/vnd.api+json"
        {
          "id":     UUID.random.to_s,
          "status": "500",
          "detail": "internal_server_error",
        }.to_json
      else
        env.response.status_code = 500
        env.response.content_type = "application/vnd.api+json"
        {
          "id":      UUID.random.to_s,
          "status":  "500",
          "detail":  "internal_server_error",
          "message": msg,
        }.to_json
      end
    end
  end
end
