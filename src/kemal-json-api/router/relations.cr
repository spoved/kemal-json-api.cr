module KemalJsonApi
  module Router
    module Relations
      # Will create a `PathInfo` containing all information needed to generate
      #  kemal routes for the resouce relation
      private def create_relation_self_path(resource : KemalJsonApi::Resource,
                                            relation : KemalJsonApi::Relation,
                                            action : KemalJsonApi::Action) : PathInfo
        case action.method
        when ActionMethod::READ
          {
            resource: resource,
            path:     "/#{resource.base_path}/:id/relationships/#{relation.name}",
            block:    ->read_relation_identifier(HTTP::Server::Context, PathInfo),
            action:   action,
          }
        when ActionMethod::LIST
          {
            resource: resource,
            path:     "/#{resource.base_path}/:id/relationships/#{relation.name}",
            block:    ->list_relation_identifiers(HTTP::Server::Context, PathInfo),
            action:   action,
          }
        else
          {
            resource: resource,
            path:     "/#{resource.base_path}/:id/relationships/#{relation.name}",
            block:    ->(env : HTTP::Server::Context, path_info : PathInfo) { "" },
            action:   action,
          }
        end
      end

      # Proc to handle listing a resource's to-one relationship via a
      #  `KemalJsonApi::Resource::Identifier`
      #
      # ```
      # {
      #   "links": {
      #     "self":    "/articles/1/relationships/author",
      #     "related": "/articles/1/author",
      #   },
      #   "data": {
      #     "type": "people",
      #     "id":   "12",
      #   },
      # }
      # ```
      private def read_relation_identifier(env : HTTP::Server::Context, path_info : PathInfo) : String
        id = env.params.url["id"]
        relation = env.route.path.to_s.split("/").last

        env.response.status_code = 200
        env.response.content_type = "application/vnd.api+json"
        env.response.headers["Connection"] = "close"
        {
          links: {
            self: env.request.path,
          },
          data: path_info[:resource].read_relation_identifier(id, relation),
        }.to_json
      end

      # Proc to handle listing resource's to-many relationships via a list of
      #  `KemalJsonApi::Resource::Identifier`
      #
      # With records
      #
      # ```
      # {
      #   "links": {
      #     "self":    "/articles/1/relationships/tags",
      #     "related": "/articles/1/tags",
      #   },
      #   "data": [
      #     {"type": "tags", "id": "2"},
      #     {"type": "tags", "id": "3"},
      #   ],
      # }
      # ```
      #
      # Without records
      #
      # ```
      # {
      #   "links": {
      #     "self": "/articles/1/relationships/tags",
      #     "related": "/articles/1/tags"
      #   },
      #   "data": []
      # }
      # ```
      private def list_relation_identifiers(env : HTTP::Server::Context, path_info : PathInfo) : String
        id = env.params.url["id"]
        relation = env.route.path.to_s.split("/").last

        ret = path_info[:resource].list_relation_identifiers(id, relation)
        env.response.status_code = 200
        env.response.content_type = "application/vnd.api+json"
        env.response.headers["Connection"] = "close"
        {
          links: {
            self: env.request.path,
          },
          data: ret,
        }.to_json
      end

      # TODO: Complete this
      private def read_relation_object(env : HTTP::Server::Context, path_info : PathInfo) : String
        ""
      end

      # TODO: Complete this
      private def list_relation_object(env : HTTP::Server::Context, path_info : PathInfo) : String
        ""
      end
    end
  end
end
