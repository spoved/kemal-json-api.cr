require "spec"
require "json"
require "../spec_helper"

# :nodoc:
class TestModel < KemalJsonApi::Resource
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
  describe "#singular" do
    it "returns a default value for singular " do
      model = TestModel.new
      model.singular.should be_a(String)
      model.singular.should eq "test_model"
    end

    it "returns the set value for singular " do
      model = TestModel.new(singular: "trait")
      model.singular.should be_a(String)
      model.singular.should eq "trait"
    end
  end

  describe "#plural" do
    it "returns a default value for plural " do
      model = TestModel.new
      model.plural.should be_a(String)
      model.plural.should eq "test_models"
    end

    it "returns the set value for plural " do
      model = TestModel.new(plural: "traits")
      model.singular.should be_a(String)
      model.singular.should eq "test_model"
      model.plural.should be_a(String)
      model.plural.should eq "traits"
    end
  end

  describe "#prefix" do
    it "returns a default value for prefix " do
      model = TestModel.new
      model.prefix.should be_a(String)
      model.prefix.should eq ""
    end

    it "returns the set value for prefix " do
      model = TestModel.new(prefix: "prefix_")
      model.prefix.should be_a(String)
      model.prefix.should eq "prefix_"
    end
  end

  describe "#collection" do
    it "returns a default value for collection " do
      model = TestModel.new
      model.collection.should be_a(String)
      model.collection.should eq "test_model"
    end

    it "returns the full value for collection " do
      model = TestModel.new(prefix: "prefix_")
      model.collection.should be_a(String)
      model.collection.should eq "prefix_test_model"
    end
  end

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
