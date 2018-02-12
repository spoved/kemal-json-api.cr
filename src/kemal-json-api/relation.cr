module KemalJsonApi
  enum RelationType
    HAS_ONE
    HAS_MANY
    HAS_AND_BELONGS_TO_MANY
    BELONGS_TO
  end

  class Relation
    property type : KemalJsonApi::RelationType
    property resource : String

    def initialize(@type : KemalJsonApi::RelationType, @resource : String)
    end
  end
end
