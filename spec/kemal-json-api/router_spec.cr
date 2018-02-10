require "../spec_helper"

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
          clear_resources
        end
      end

      describe ".add" do
        KemalJsonApi::Router.resources.empty?.should be_true
        KemalJsonApi::Router.add TestResource.new(adapter)
        KemalJsonApi::Router.resources.empty?.should be_false
        clear_resources
      end
    end

    context "with resources" do
      pending ".generate_routes!" do
      end
    end
  end
end
