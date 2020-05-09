module KemalJsonApi
  abstract class Adapter
    # Returns the name of the configured database for this adapter instance
    property! database_name : String

    # abstract def with_database(&block) : Nil
    abstract def uri : String
  end
end
