module KemalJsonApi
  abstract class Model
    # actions
    abstract def create(args : Hash(String, String)) : Int | Nil
    abstract def read(id : Int | String) : Hash(String, String) | Nil
    abstract def update(id : Int | String, args : Hash(String, String)) : Int | Nil
    abstract def delete(id : Int | String) : Int | Nil
    abstract def list : Array(Hash(String, String))
    # misc
    abstract def prepare_params(env : HTTP::Server::Context, *, json = true) : Hash(String, String)
  end
end
