module KemalJsonApi
  module Router
    module Relations
      # Will create a `PathInfo` containing all information needed to generate
      #  kemal routes for the resouce relation
      private def create_relation_path(resource : KemalJsonApi::Resource,
                                       relation : KemalJsonApi::Relation,
                                       action : KemalJsonApi::Action) : PathInfo
        case action.method
        when ActionMethod::READ
          {
            resource: resource,
            path:     "/#{resource.base_path}/:id/relationships/#{relation.name}",
            block:    ->read_relationship(HTTP::Server::Context, PathInfo),
            action:   action,
          }
        when ActionMethod::LIST
          {
            resource: resource,
            path:     "/#{resource.base_path}/:id/relationships/#{relation.name}",
            block:    ->list_relationships(HTTP::Server::Context, PathInfo),
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

      # Proc to handle listing a resource's to-one relationship
      private def read_relationship(env : HTTP::Server::Context, path_info : PathInfo) : String
        id = env.params.url["id"]
      end

      # Proc to handle listing resource's to-many relationships
      private def list_relationships(env : HTTP::Server::Context, path_info : PathInfo) : String
        id = env.params.url["id"]
      end
    end
  end
end
