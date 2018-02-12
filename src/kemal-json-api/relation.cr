module KemalJsonApi
  enum RelationType
    # to-one
    HAS_ONE
    BELONGS_TO
    # to-many
    HAS_MANY
    HAS_AND_BELONGS_TO_MANY
  end

  # http://jsonapi.org/format/#document-resource-object-relationships
  class Relation
    property type : KemalJsonApi::RelationType
    property resource : String

    def initialize(@type : KemalJsonApi::RelationType, @resource : String)
    end

    # Alias for `relation_name`
    def name : String
      relation_name
    end

    # Will pluralize resource based on `KemalJsonApi::RelationType`
    def relation_name : String
      case self.type
      when KemalJsonApi::RelationType::BELONGS_TO
        resource
      when KemalJsonApi::RelationType::HAS_ONE
        resource
      when KemalJsonApi::RelationType::HAS_MANY
        resource.pluralize
      when KemalJsonApi::RelationType::HAS_AND_BELONGS_TO_MANY
        resource.pluralize
      else
        resource
      end
    end
  end
end
