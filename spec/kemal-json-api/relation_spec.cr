require "../spec_helper"

describe KemalJsonApi do
  describe KemalJsonApi::RelationType do
    describe KemalJsonApi::RelationType::HAS_ONE do
      it "has value" do
        KemalJsonApi::RelationType::HAS_ONE.value.should_not be_nil
      end
    end

    describe KemalJsonApi::RelationType::BELONGS_TO do
      it "has value" do
        KemalJsonApi::RelationType::BELONGS_TO.value.should_not be_nil
      end
    end

    describe KemalJsonApi::RelationType::HAS_MANY do
      it "has value" do
        KemalJsonApi::RelationType::HAS_MANY.value.should_not be_nil
      end
    end

    describe KemalJsonApi::RelationType::HAS_AND_BELONGS_TO_MANY do
      it "has value" do
        KemalJsonApi::RelationType::HAS_AND_BELONGS_TO_MANY.value.should_not be_nil
      end
    end
  end

  describe KemalJsonApi::Relation do
    context "type is HAS_ONE" do
      describe "#new" do
        it "should create object" do
          relation = KemalJsonApi::Relation.new(
            KemalJsonApi::RelationType::HAS_ONE,
            "trait"
          )
          relation.should_not be_nil
          relation.should be_a(KemalJsonApi::Relation)
        end
      end

      describe "#type" do
        it "should return correct type" do
          relation = KemalJsonApi::Relation.new(
            KemalJsonApi::RelationType::HAS_ONE,
            "trait"
          )
          relation.should_not be_nil
          relation.type.should eq KemalJsonApi::RelationType::HAS_ONE
        end
      end

      describe "#resource" do
        it "should return correct resource" do
          relation = KemalJsonApi::Relation.new(
            KemalJsonApi::RelationType::HAS_ONE,
            "trait"
          )
          relation.should_not be_nil
          relation.resource.should eq "trait"
        end
      end

      describe "#name" do
        it "returns correct name" do
          relation = KemalJsonApi::Relation.new(
            KemalJsonApi::RelationType::HAS_ONE,
            "trait"
          )
          relation.should_not be_nil
          relation.name.should eq "trait"
        end
      end
    end

    context "type is BELONGS_TO" do
      describe "#new" do
        it "should create object" do
          relation = KemalJsonApi::Relation.new(
            KemalJsonApi::RelationType::HAS_ONE,
            "trait"
          )
          relation.should_not be_nil
          relation.should be_a(KemalJsonApi::Relation)
        end
      end

      describe "#type" do
        it "should return correct type" do
          relation = KemalJsonApi::Relation.new(
            KemalJsonApi::RelationType::HAS_ONE,
            "trait"
          )
          relation.should_not be_nil
          relation.type.should eq KemalJsonApi::RelationType::HAS_ONE
        end
      end

      describe "#resource" do
        it "should return correct resource" do
          relation = KemalJsonApi::Relation.new(
            KemalJsonApi::RelationType::HAS_ONE,
            "trait"
          )
          relation.should_not be_nil
          relation.resource.should eq "trait"
        end
      end

      describe "#name" do
        it "returns correct name" do
          relation = KemalJsonApi::Relation.new(
            KemalJsonApi::RelationType::BELONGS_TO,
            "trait"
          )
          relation.should_not be_nil
          relation.name.should eq "trait"
        end
      end
    end

    context "type is HAS_MANY" do
      describe "#new" do
        it "should create object" do
          relation = KemalJsonApi::Relation.new(
            KemalJsonApi::RelationType::HAS_MANY,
            "trait"
          )
          relation.should_not be_nil
          relation.should be_a(KemalJsonApi::Relation)
        end
      end

      describe "#type" do
        it "should return correct type" do
          relation = KemalJsonApi::Relation.new(
            KemalJsonApi::RelationType::HAS_MANY,
            "trait"
          )
          relation.should_not be_nil
          relation.type.should eq KemalJsonApi::RelationType::HAS_MANY
        end
      end

      describe "#resource" do
        it "should return correct resource" do
          relation = KemalJsonApi::Relation.new(
            KemalJsonApi::RelationType::HAS_ONE,
            "trait"
          )
          relation.should_not be_nil
          relation.resource.should eq "trait"
        end
      end

      describe "#name" do
        it "returns correct name" do
          relation = KemalJsonApi::Relation.new(
            KemalJsonApi::RelationType::HAS_MANY,
            "trait"
          )
          relation.should_not be_nil
          relation.name.should eq "traits"
        end
      end
    end

    context "type is HAS_AND_BELONGS_TO_MANY" do
      describe "#new" do
        it "should create object" do
          relation = KemalJsonApi::Relation.new(
            KemalJsonApi::RelationType::HAS_AND_BELONGS_TO_MANY,
            "trait"
          )
          relation.should_not be_nil
          relation.should be_a(KemalJsonApi::Relation)
        end
      end

      describe "#type" do
        it "should return correct type" do
          relation = KemalJsonApi::Relation.new(
            KemalJsonApi::RelationType::HAS_AND_BELONGS_TO_MANY,
            "trait"
          )
          relation.should_not be_nil
          relation.type.should eq KemalJsonApi::RelationType::HAS_AND_BELONGS_TO_MANY
        end
      end

      describe "#resource" do
        it "should return correct resource" do
          relation = KemalJsonApi::Relation.new(
            KemalJsonApi::RelationType::HAS_AND_BELONGS_TO_MANY,
            "trait"
          )
          relation.should_not be_nil
          relation.resource.should eq "trait"
        end
      end

      describe "#name" do
        it "returns correct name" do
          relation = KemalJsonApi::Relation.new(
            KemalJsonApi::RelationType::HAS_AND_BELONGS_TO_MANY,
            "trait"
          )
          relation.should_not be_nil
          relation.name.should eq "traits"
        end
      end
    end
  end
end
