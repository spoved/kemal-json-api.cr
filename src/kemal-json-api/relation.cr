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

    # Will return a singular or pluralized resource name
    #  based on `KemalJsonApi::RelationType`
    def name : String
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
