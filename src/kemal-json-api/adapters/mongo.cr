require "../adapter"
require "mongo"

module KemalJsonApi
  abstract class Adapter::Mongo < KemalJsonApi::Adapter
    # Returns the requested database
    abstract def database(database : String) : ::Mongo::Database

    # Returns the requested collection
    abstract def collection(collection : String, db : ::Mongo::Database? = nil) : ::Mongo::Collection

    # Returns the mongodb connection URI
    abstract def uri : String

    abstract def with_database(&block : ::Mongo::Database -> Nil) : Nil

    abstract def with_collection(collection : String, &block : ::Mongo::Collection -> Nil) : Nil
  end
end
