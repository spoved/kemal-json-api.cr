module KemalJsonApi
  module Router
    module Resources
      # Will create a `PathInfo` containing all information needed to generate
      #  kemal routes
      private def create_resource_path(resource : KemalJsonApi::Resource, action : KemalJsonApi::Action) : PathInfo
        case action.method
        when ActionMethod::CREATE
          {
            resource: resource,
            path:     "/#{resource.base_path}",
            block:    ->create_resource(HTTP::Server::Context, PathInfo),
            action:   action,
          }
        when ActionMethod::READ
          {
            resource: resource,
            path:     "/#{resource.base_path}/:id",
            block:    ->read_resource(HTTP::Server::Context, PathInfo),
            action:   action,
          }
        when ActionMethod::UPDATE
          {
            resource: resource,
            path:     "/#{resource.base_path}/:id",
            block:    ->update_resource(HTTP::Server::Context, PathInfo),
            action:   action,
          }
        when ActionMethod::DELETE
          {
            resource: resource,
            path:     "/#{resource.base_path}/:id",
            block:    ->delete_resource(HTTP::Server::Context, PathInfo),
            action:   action,
          }
        when ActionMethod::LIST
          {
            resource: resource,
            path:     "/#{resource.base_path}",
            block:    ->list_resource(HTTP::Server::Context, PathInfo),
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

      # Proc to handle updating resources
      private def update_resource(env : HTTP::Server::Context, path_info : PathInfo) : String
        id = env.params.url["id"]
        updated = false
        data = path_info[:resource].prepare_params(env)
        if data.has_key?("data") && data["data"].as_h.has_key?("type")
          args = data["data"].as_h
          updated = path_info[:resource].update(id, args["attributes"].as_h)
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
      private def delete_resource(env : HTTP::Server::Context, path_info : PathInfo) : String
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
      private def list_resource(env : HTTP::Server::Context, path_info : PathInfo) : String
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
      private def read_resource(env : HTTP::Server::Context, path_info : PathInfo) : String
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
          Log.error { "failed to read resource" }
          error env, 404
        end
      end

      # Proc to handle create resources
      private def create_resource(env : HTTP::Server::Context, path_info : PathInfo) : String
        # TODO: let pass only valid fields
        data = path_info[:resource].prepare_params(env)
        if data.has_key?("data") && data["data"].as_h.has_key?("type")
          args = data["data"].as_h
          id = path_info[:resource].create(args["attributes"].as_h)
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
    end
  end
end
