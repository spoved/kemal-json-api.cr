require "../spec_helper"
require "../../src/kemal-json-api/macros/router"

describe KemalJsonApi do
  describe KemalJsonApi::Router do
    context "with no resources" do
      clear_resources

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

        it "renders /" do
          begin
            get "/characters"
            puts response.inspect
          rescue ex
            puts ex.backtrace
          end
          # response.body.should eq "Hello World!"
        end
      end
    end
  end
end
