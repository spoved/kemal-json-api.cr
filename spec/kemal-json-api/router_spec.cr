require "../spec_helper"
require "../../src/kemal-json-api/macros/router"

describe KemalJsonApi do
  describe KemalJsonApi::Router do
    context "with no resources" do
      describe ".resources" do
        it "has resources array" do
          KemalJsonApi::Router.resources.should_not be_nil
          KemalJsonApi::Router.resources.empty?.should be_true
        end

        it "can set resources" do
          KemalJsonApi::Router.resources.empty?.should be_true
          KemalJsonApi::Router.resources = [TestResource.new(adapter)] of KemalJsonApi::Resource
          KemalJsonApi::Router.resources.empty?.should be_false
        end
      end

      describe ".add" do
        it "can add new resource" do
          KemalJsonApi::Router.resources.empty?.should be_true
          KemalJsonApi::Router.add TestResource.new(adapter)
          KemalJsonApi::Router.resources.empty?.should be_false
        end
      end
    end

    context "with resources" do
      describe ".generate_routes!" do
        it "can generate routes" do
          KemalJsonApi::Router.resources.empty?.should be_true
          json_api_resource "character", adapter
          KemalJsonApi::Router.resources.empty?.should be_false
          KemalJsonApi::Router.generate_routes!
          add_handler KemalJsonApi::Handler.new
          Kemal.run
        end

        describe "GET /characters" do
          it "renders /characters" do
            json = get_characters
            json.should_not be_nil
          end

          it "has correct number of characters" do
            json = get_characters
            json["data"].as_a.empty?.should be_false
            json["data"].as_a.size.should eq 2
          end

          it "has correct link to self" do
            json = get_characters
            json["links"].as_h["self"].should eq "/characters"
          end
        end

        describe "GET /characters/:id" do
          it "renders /characters/:id" do
            json = get_characters("5a7f723025ae0bfae26b43d1")
            json.should_not be_nil
          end

          it "has correct link to self" do
            json = get_characters("5a7f723025ae0bfae26b43d1")
            json["links"].as_h["self"].should eq "/characters/5a7f723025ae0bfae26b43d1"
          end

          it "has correct resource" do
            json = get_characters("5a7f723025ae0bfae26b43d1")
            json["data"].should_not be_nil
            hash = json["data"].as_h
            hash["type"].should eq "characters"
            hash["id"].should eq "5a7f723025ae0bfae26b43d1"
          end
        end

        describe "POST /characters" do
          it "creates new resource" do
            json = post_characters(Hash(String, String){"name" => "Ringo"})
            json.should_not be_nil
            json["data"].should_not be_nil
            hash = json["data"].as_h
            hash["type"].should eq "characters"
            attrs = hash["attributes"].as(Hash(String, JSON::Type))
            attrs["name"].should eq "Ringo"
          end
        end

        describe "PATCH /characters/:id" do
          it "update resource" do
            json = post_characters(Hash(String, String){"name" => "Ringo", "age" => "44"})
            json.should_not be_nil
            json["data"].should_not be_nil
            hash = json["data"].as_h
            hash["type"].should eq "characters"
            attrs = hash["attributes"].as(Hash(String, JSON::Type))
            attrs["name"].should eq "Ringo"
            id = hash["id"].as(String)

            update = patch_characters(id, Hash(String, String){"name" => "Dingo"})
            update.should_not be_nil
            update["data"].should_not be_nil
            hash = update["data"].as_h
            hash["type"].should eq "characters"
            attrs = hash["attributes"].as(Hash(String, JSON::Type))
            attrs["name"].should eq "Dingo"
            attrs["age"].should eq "44"
          end
        end

        describe "DELETE /characters/:id" do
          it "deletes resource" do
            json = post_characters(Hash(String, String){"name" => "Ringo"})
            json.should_not be_nil
            json["data"].should_not be_nil
            hash = json["data"].as_h
            hash["type"].should eq "characters"
            attrs = hash["attributes"].as(Hash(String, JSON::Type))
            attrs["name"].should eq "Ringo"
            id = hash["id"].as(String)

            delete_characters(id).should eq 200
          end
        end
      end
    end
  end
end
