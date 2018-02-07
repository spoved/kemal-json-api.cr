require "spec"
require "json"
require "../../src/kemal-json-api/model"

class TestModel < KemalJsonApi::Model
  def create(data : JSON::Type) : String | Nil
    "550e8400-e29b-41d4-a716-446655440000"
  end

  def read(id : Int | String) : JSON::Type | Nil
    JSON.parse({
      "type":       "articles",
      "id":         "1",
      "attributes": {
        "title": "JSON API paints my bikeshed!",
      },
      "relationships": {
        "author": {
          "links": {
            "related": "http://example.com/articles/1/author",
          },
        },
      },
    }.to_json).as_h
  end

  def update(id : Int | String, args : JSON::Type) : JSON::Type | Nil
    JSON.parse({
      "type":       "articles",
      "id":         "1",
      "attributes": {
        "title": "JSON API paints my bikeshed!",
      },
      "relationships": {
        "author": {
          "links": {
            "related": "http://example.com/articles/1/author",
          },
        },
      },
    }.to_json).as_h
  end

  def delete(id : Int | String) : Bool | Nil
    true
  end

  def list : Array(JSON::Type)
    JSON.parse([{
      "type":       "articles",
      "id":         "1",
      "attributes": {
        "title": "JSON API paints my bikeshed!",
      },
    }, {
      "type":       "articles",
      "id":         "2",
      "attributes": {
        "title": "Rails is Omakase",
      },
    }].to_json).as_a
  end
end

describe TestModel do
  describe "#create" do
    it "returns a String id on create" do
      result = TestModel.new.create({"data" => "data"})
      result.should be_a(String)
      result.should eq "550e8400-e29b-41d4-a716-446655440000"
    end
  end

  describe "#read" do
    it "returns a Hash on read" do
      result = TestModel.new.read("1")
      result.should be_a Hash(String, JSON::Type)
    end
  end

  describe "#update" do
    it "returns a Hash on update" do
      data = {"title" => "JSON API paints my bikeshed!"}
      result = TestModel.new.update("1", data)
      result.should be_a Hash(String, JSON::Type)
    end
  end

  describe "#delete" do
    it "returns a Hash on update" do
      result = TestModel.new.delete("1")
      result.should be_true
    end
  end

  describe "#list" do
    it "returns a Hash on list" do
      result = TestModel.new.list
      result.should be_a Array(JSON::Type)
    end
  end
end
