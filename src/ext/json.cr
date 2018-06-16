struct JSON::Any
  def to_bson
    BSON.from_json(self.to_json)
  end
end
