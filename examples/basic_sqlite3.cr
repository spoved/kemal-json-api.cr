# --------------------------------------------------------------------------- #
# kemal-json-api basic example
# --------------------------------------------------------------------------- #
require "db"
require "sqlite3"
require "kemal"
require "../src/*"

DB_CONNECTION = "sqlite3:./db.sqlite3"

def create_table1
  table = "Test"
  DB.open DB_CONNECTION do |db|
    if db.scalar("SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name='#{table}'") == 0
      puts "> Create table #{table}"
      db.exec "CREATE TABLE #{table}( id INTEGER PRIMARY KEY, name STRING, age INTEGER )"
    end
  end
  table
end

class MyModel < KemalJsonApi::Adapters::CrystalDbModel
  def initialize
    super DB_CONNECTION, create_table1
  end
end

# # Simple:
# KemalJsonApi::Resource.new MyModel.new

# # Change some options:
# KemalJsonApi::Resource.new MyModel.new, KemalJsonApi::ALL_ACTIONS, singular: "item"

# # Setup only specific routes:
# KemalJsonApi::Resource.new MyModel.new, {
#   KemalJsonApi::ActionMethod::READ => KemalJsonApi::ActionType::GET,
#   KemalJsonApi::ActionMethod::LIST => KemalJsonApi::ActionType::GET,
#   KemalJsonApi::ActionMethod::UPDATE => KemalJsonApi::ActionType::PATCH,
# }, singular: "test"

module WebApp
  res = KemalJsonApi::Resource.new MyModel.new, KemalJsonApi::ALL_ACTIONS, singular: "item"

  # Routes
  get "/" do |env|
    env.response.content_type = "text/plain"
    "Just a test..."
  end

  res.generate_routes!

  # Starts Kemal
  Kemal.run
end
