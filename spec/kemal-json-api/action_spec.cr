require "../spec_helper"
begin
  describe KemalJsonApi do
    describe KemalJsonApi::ActionMethod do
      describe KemalJsonApi::ActionMethod::CREATE do
        it "has value" do
          KemalJsonApi::ActionMethod::CREATE.value.should_not be_nil
        end
      end

      describe KemalJsonApi::ActionMethod::READ do
        it "has value" do
          KemalJsonApi::ActionMethod::READ.value.should_not be_nil
        end
      end

      describe KemalJsonApi::ActionMethod::UPDATE do
        it "has value" do
          KemalJsonApi::ActionMethod::UPDATE.value.should_not be_nil
        end
      end

      describe KemalJsonApi::ActionMethod::DELETE do
        it "has value" do
          KemalJsonApi::ActionMethod::DELETE.value.should_not be_nil
        end
      end

      describe KemalJsonApi::ActionMethod::LIST do
        it "has value" do
          KemalJsonApi::ActionMethod::LIST.value.should_not be_nil
        end
      end
    end

    describe KemalJsonApi::ActionType do
      describe KemalJsonApi::ActionType::GET do
        it "has value" do
          KemalJsonApi::ActionType::GET.value.should_not be_nil
        end
      end

      describe KemalJsonApi::ActionType::POST do
        it "has value" do
          KemalJsonApi::ActionType::POST.value.should_not be_nil
        end
      end

      describe KemalJsonApi::ActionType::PUT do
        it "has value" do
          KemalJsonApi::ActionType::PATCH.value.should_not be_nil
        end
      end

      describe KemalJsonApi::ActionType::PATCH do
        it "has value" do
          KemalJsonApi::ActionType::PATCH.value.should_not be_nil
        end
      end

      describe KemalJsonApi::ActionType::DELETE do
        it "has value" do
          KemalJsonApi::ActionType::DELETE.value.should_not be_nil
        end
      end
    end

    describe KemalJsonApi::Action do
      describe "#new" do
        action = KemalJsonApi::Action.new(
          KemalJsonApi::ActionMethod::READ,
          KemalJsonApi::ActionType::GET
        )
        action.should_not be_nil
        action.should be_a(KemalJsonApi::Action)
      end

      describe "#method" do
        action = KemalJsonApi::Action.new(
          KemalJsonApi::ActionMethod::READ,
          KemalJsonApi::ActionType::GET
        )
        action.should_not be_nil
        action.method.should eq KemalJsonApi::ActionMethod::READ
      end

      describe "#type" do
        action = KemalJsonApi::Action.new(
          KemalJsonApi::ActionMethod::READ,
          KemalJsonApi::ActionType::DELETE
        )
        action.should_not be_nil
        action.type.should eq KemalJsonApi::ActionType::DELETE
      end
    end
  end
rescue ex
  puts ex.inspect
end
