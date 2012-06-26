require 'spec_helper'

describe Unsubscribe do
  context "an initialized object" do
    let(:unsubscribe) {Unsubscribe.new}

    subject { unsubscribe }

    it { should validate_presence_of(:petition) }
    it { should validate_presence_of(:signature) }
    it { should validate_presence_of(:email) }

    it { should allow_value('foo@bar.com').for(:email) }
    it { should_not allow_value('hey there').for(:email) }

    describe "PetitionAndSignatureMustMatchValidator" do

      before :each do
        @campaigner = Factory.build(:user)
        @petition = Factory.build(:petition, user: @campaigner)
        @signature = Factory.build(:signature, petition: @petition)
        @unsubscribe = Unsubscribe.new(petition: @petition, email: @signature.email, signature: @signature)
      end

      it "should not valid if petition not match" do
        @unsubscribe.petition = Factory.build(:petition)
        @unsubscribe.valid?
        @unsubscribe.errors[:base].should == ["The signature and the petition must match"]
        @unsubscribe.errors[:email].should be_blank
      end

      it "should not valid if signature email not match" do
        @unsubscribe.email = "random@email.com"
        @unsubscribe.valid?
        @unsubscribe.errors[:email].should == ["does not match."]
        @unsubscribe.errors[:base].should be_blank
      end

      it "should match signature email case insensitive " do
        @unsubscribe.email = @signature.email
        @unsubscribe.valid?
        @unsubscribe.errors[:email].should be_blank
        @unsubscribe.errors[:base].should be_blank

        @unsubscribe.email = @signature.email.capitalize
        @unsubscribe.valid?
        @unsubscribe.errors[:email].should be_blank
        @unsubscribe.errors[:base].should be_blank
      end
    end

    describe "NoUnsubFromOwnPetitionValidator" do
      it "should not allow petition owner to unsubscribe with email insensitive" do
        campaigner = Factory.build(:user)
        unsubscribe = Unsubscribe.new(petition: Factory.build(:petition, user: campaigner))

        unsubscribe.email = campaigner.email
        unsubscribe.valid?
        unsubscribe.errors[:email].should be_blank
        unsubscribe.errors[:base].should ==  ["You can not unsubscribe from your own campaign."]

        unsubscribe.email = campaigner.email.capitalize
        unsubscribe.valid?
        unsubscribe.errors[:email].should be_blank
        unsubscribe.errors[:base].should ==  ["You can not unsubscribe from your own campaign."]
      end
    end
  end

  describe "initialization" do
    before(:each) do
      @unsubscribe = Unsubscribe.new :email => 'email@foo.com'
    end

    specify{ @unsubscribe.email.should == 'email@foo.com'}
  end

  describe "#persisted?" do
    specify{ Unsubscribe.new.persisted?.should be_false}
  end


end
