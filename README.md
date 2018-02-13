# kemal-json-api [![Build Status](https://travis-ci.org/spoved/kemal-json-api.cr.svg?branch=master)](https://travis-ci.org/spoved/kemal-json-api.cr)

A Crystal library to create JSON API with Kemal.

See [examples](https://github.com/spoved/kemal-json-api.cr/tree/master/examples) folder for **mongo** samples.

**NOTE**: this is a *beta* version, a lot of features and security improvements need to be implemented actually

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  kemal-json-api:
    github: spoved/kemal-json-api.cr
```

## Usage

```ruby
require "mongo"
require "kemal"
require "kemal-json-api"

mongodb = KemalJsonApi::Adapter::Mongo.new("localhost", 27017, "test")

class MyModel < KemalJsonApi::Resource::Mongo
end

module WebApp
  KemalJsonApi::Router.add MyModel.new(mongodb, actions: KemalJsonApi::ALL_ACTIONS, prefix: "api", singular: "item")
  KemalJsonApi::Router.generate_routes!
  add_handler KemalJsonApi::Handler.new
  Kemal.run
end
```

Generated routes:

```
GET    /api/items
GET    /api/items/:id
POST   /api/items
PATCH  /api/items/:id
DELETE /api/items/:id
```

## Macro
kemal-json-api also has a macro that can be used to shortcut creating routes

```ruby
require "mongo"
require "kemal"
require "../src/kemal-json-api/macros/router"

mongodb = KemalJsonApi::Adapter::Mongo.new("localhost", 27017, "test")

module WebApp
  json_api_resource "trait", mongodb

  KemalJsonApi::Router.generate_routes!
  add_handler KemalJsonApi::Handler.new
  Kemal.run
end
```

## KemalJsonApi::Resource options

- **plural** (*String*): plural name of the model, used for routes, default = *singular* pluralized
- **prefix** (*String*): prefix for all API routes, default = ""
- **singular** (*String*): singular name of the model, default = class model name lowercase

## More examples

See [examples](https://github.com/spoved/kemal-json-api.cr/tree/master/examples) folder.

## Notes

Currently Mongodb is the only adapter available

## Contributors

- [Holden Omans](https://github.com/kalinon) - creator, maintainer, Crystal fan
