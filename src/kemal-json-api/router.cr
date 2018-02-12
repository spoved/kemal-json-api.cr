require "kemal"
require "./router/*"

module KemalJsonApi
  module Router
    extend Relations
    extend Resources
    extend self

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
    def add(resource : KemalJsonApi::Resource)
      @@resources.push resource
    end

    # Will generate kemal routes based on regisered resources
    def generate_routes! : Nil
      resources.each do |resource|
        resource.actions.each do |action|
          path_info = create_resource_path(resource, action)
          create_route(path_info) unless path_info[:path].empty?
        end

        resource.relations.each do |rel|
          if rel.type == KemalJsonApi::RelationType::HAS_ONE ||
             rel.type == KemalJsonApi::RelationType::BELONGS_TO
            path_info = create_relation_path(resource, rel,
              KemalJsonApi::Action.new(
                KemalJsonApi::ActionMethod::READ, KemalJsonApi::ActionType::GET
              )
            )
            create_route(path_info) unless path_info[:path].empty?
          elsif rel.type == KemalJsonApi::RelationType::HAS_MANY ||
                rel.type == KemalJsonApi::RelationType::HAS_AND_BELONGS_TO_MANY
            path_info = create_relation_path(resource, rel,
              KemalJsonApi::Action.new(
                KemalJsonApi::ActionMethod::LIST, KemalJsonApi::ActionType::GET
              )
            )
            create_route(path_info) unless path_info[:path].empty?
          end
        end
      end

      add_handler KemalJsonApi::Handler.new
      nil
    end

    # Will create kemal route based on the `PathInfo`
    private def create_route(path_info : PathInfo)
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

    # Will set `HTTP::Server::Context` status_code and content_type, will return
    #  error json stringbased on passed code
    private def error(env : HTTP::Server::Context, code : Int32, msg : String = "") : String
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
