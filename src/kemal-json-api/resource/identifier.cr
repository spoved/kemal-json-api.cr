module KemalJsonApi
  # Abstract class to represent a JSON API resource object
  # See http://jsonapi.org/format/#document-resource-objects for proper format
  #  of the returns
  abstract class Resource
    # Class to represent a JSON API Resource Identifier Object
    # See http://jsonapi.org/format/#document-resource-identifier-objects
    class Identifier
      JSON.mapping(
        type: {type: String, getter: true, setter: true},
        id: {type: String, getter: true, setter: true},
      )

      def initialize(@type : String, @id : String)
      end

      def to_h : Hash(String, String)
        Hash(String, String){
          "type" => self.type,
          "id"   => self.id,
        }
      end
    end
  end
end
