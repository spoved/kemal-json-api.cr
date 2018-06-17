class BSON
  def []=(key, value : Array(JSON::Any))
    self[key] = BSON.from_json(value.to_json)
  end

  def []=(key, value : Hash(String, JSON::Any))
    self[key] = BSON.from_json(value.to_json)
  end

  def []=(key, value : JSON::Any)
    self[key] = value.raw
  end
end
