require "../../spec_helper"
begin
  describe KemalJsonApi do
    describe KemalJsonApi::Resource do
      describe KemalJsonApi::Resource::Mongo do
        describe "#singular" do
          it "returns expected value for singular " do
            resource = mongo_resource_character
            resource.singular.should be_a(String)
            resource.singular.should eq "character"
          end
        end

        describe "#plural" do
          it "returns expected value for plural " do
            resource = mongo_resource_character
            resource.plural.should be_a(String)
            resource.plural.should eq "characters"
          end
        end

        describe "#collection" do
          it "returns a default value for collection " do
            resource = mongo_resource_character
            resource.collection.should be_a(String)
            resource.collection.should eq "character"
          end
        end

        describe "#create" do
          it "returns a String id on create" do
            result = mongo_resource_character.create({"id" => "5a7f723025ae0bfae26b43d3", "name" => "Morty"})
            result.should be_a(String)
            result.should eq "5a7f723025ae0bfae26b43d3"
          end
        end

        describe "#read" do
          it "returns a Hash on read" do
            result = mongo_resource_character.read("5a7f723025ae0bfae26b43d1")
            result.should be_a Hash(String, JSON::Type)
          end
        end

        describe "#update" do
          it "returns a Bool on update" do
            data = {"name" => "James Bonadale"}
            result = mongo_resource_character.update("5a7f723025ae0bfae26b43d1", data)
            result.should be_true

            char = mongo_resource_character.read("5a7f723025ae0bfae26b43d1")
            char.should_not be_nil
          end
        end

        describe "#delete" do
          it "returns a Bool on update" do
            result = mongo_resource_character.delete("5a7f723025ae0bfae26b43d1")
            result.should be_true
          end
        end

        describe "#list" do
          it "returns a Hash on list" do
            result = mongo_resource_character.list
            result.should be_a Array(JSON::Type)
          end
        end
      end
    end
  end
rescue ex
  puts ex.inspect
end
