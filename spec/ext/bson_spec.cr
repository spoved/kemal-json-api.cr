require "../spec_helper"

describe JSON::Any do
  describe "#to_bson" do
    json = %({"id":"5a7f723025ae0bfae26b43d3","name":"Morty"})

    it "correctly converts to BSON" do
      BSON.from_json(json).should_not be_nil
      JSON.parse(json).as_h.to_bson.should_not be_nil
      JSON.parse(json).as_h.to_bson.should be_a(BSON)
      JSON.parse(%({"name":"James Bonadale"})).as_h.to_bson.should be_a(BSON)
    end

    it "correctly converts Hash to BSON" do
      h = Hash(String, JSON::Any){"name" => JSON::Any.new("James Bonadale")}
      h.to_bson.should be_a(BSON)
    end
  end
end
