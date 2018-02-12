require "../adapter"
require "mongo"

module KemalJsonApi
  class Adapter::Mongo < KemalJsonApi::Adapter
    # Returns the mongodb instance host or ip
    property host : String = "localhost"
    # Returns the mongodb instance port
    property port : Int32 = 27017
    # Returns the name of the configured database for this adapter instance
    property! database_name : String

    def initialize(@host : String, @port : Int32, @database_name : String)
    end

    # Returns the mongo client
    def get_client : ::Mongo::Client
      ::Mongo::Client.new(self.uri)
    end

    # Returns the requested database
    def get_database(database : String) : ::Mongo::Database
      client = get_client
      client[database]
    end

    # Returns the requested collection
    def get_collection(collection : String) : ::Mongo::Collection
      db = get_database(self.database_name)
      db[collection]
    end

    # Returns the mongodb connection URI
    def uri : String
      "mongodb://#{host}:#{port}/#{database_name}"
    end

    def with_database
      db = get_database(self.database_name)
      begin
        yield db
      ensure
        # db.drop
      end
    end

    def with_collection(collection : String)
      with_database do |db|
        col = self.get_collection(collection)
        yield col
      end
    end
  end
end
