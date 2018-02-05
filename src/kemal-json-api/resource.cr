require "./action"
require "./model"

module KemalJsonApi
  class Resource
    @resources = [] of Resource
    @actions = [] of Action
    @singular : String
    @plural : String
    @option_json : Bool

    getter :actions, :model, :singular, :prefix, :plural

    alias ActionsList = Hash(ActionMethod, ActionType)

    def initialize(@model : Model, actions : ActionsList = ALL_ACTIONS, *, json = true, plural = "", prefix = "", singular = "")
      @singular = singular.strip.empty? ? typeof(model).to_s.downcase : singular.strip
      @prefix = prefix.strip.empty? ? "" : prefix.strip
      @plural = plural.strip.empty? ? Resource.pluralize(@singular) : plural.strip
      @option_json = json
      @resources.push self
      setup_actions! actions
    end

    def set_options(*, json = true)
      @option_json = json
    end

    def reset!
      @resources.clear
    end

    def self.pluralize(string)
      case string
      when /(s|x|z|ch)$/
        "#{string}es"
      when /(a|e|i|o|u)y$/
        "#{string}s"
      when /y$/
        "#{string[0..-2]}ies"
      when /f$/
        "#{string[0..-2]}ves"
      when /fe$/
        "#{string[0..-3]}ves"
      else
        "#{string}s"
      end
    end

    def read(id : String) : String
      ret = model.read id
      ret.to_json

      begin
        ret = model.read(id)
        {
          links: {
            self: "/#{plural}/#{id}",
          },
          data: convert_to_json_api(id, ret),
        }.to_json
      rescue
        {
          links: {
            self: "/#{plural}/#{id}",
          },
          data: nil,
        }.to_json
      end
    end

    def list
      ret = [] of Hash(String, String) | Nil | JSON::Any
      model.list.each do |value|
        id = value.has_key?("_id") ? value["_id"].to_s.chomp('\u0000') : value["id"].to_s
        ret.push convert_to_json_api(id, value)
      end

      {
        links: {
          self: "/#{plural}",
        },
        data: ret,
      }.to_json
    end

    def convert_to_json_api(id : String, hash : Hash(String, String) | BSON | Nil)
      return nil unless hash
      json = JSON.parse(hash.to_json).as_h
      json.delete_if { |key, value| key =~ /^(id|_id)$/ }
      JSON.parse({
        type:       plural,
        id:         id,
        attributes: json,
      }.to_json)
    end

    protected def setup_actions!(actions = {} of Action::Method => Action::MethodType)
      if !actions || actions.empty?
        @actions.push Action.new(ActionMethod::CREATE, ActionType::POST)
        @actions.push Action.new(ActionMethod::READ, ActionType::GET)
        @actions.push Action.new(ActionMethod::UPDATE, ActionType::PUT)
        @actions.push Action.new(ActionMethod::DELETE, ActionType::DELETE)
        @actions.push Action.new(ActionMethod::LIST, ActionType::GET)
      else
        actions.each do |k, v|
          @actions.push Action.new(k, v)
        end
      end
    end
  end
end
