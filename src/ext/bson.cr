class BSON
  def []=(key, value : JSON::Any)
    self[key] = value.to_bson
  end
end
