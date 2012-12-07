require 'spec_helper'

describe GroupUnsubscribe do
  context "an initialized object" do
    let(:unsubscribe) { GroupUnsubscribe.new }

    subject { unsubscribe }

    it { should validate_presence_of(:subscription) }
    it { should validate_presence_of(:email) }

    it { should allow_value('foo@bar.com').for(:email) }
    it { should_not allow_value('hey there').for(:email) }

    describe "#persisted?" do
      specify{ subject.persisted?.should be_false}
    end
  end

  describe "initialization" do
    before(:each) do
      @unsubscribe = GroupUnsubscribe.new :email => 'email@foo.com'
    end

    specify{ @unsubscribe.email.should == 'email@foo.com'}
  end

  describe "invalid unsubscribe attempt" do
    it "should return nil" do
      GroupUnsubscribe.new.unsubscribe.should be_nil
    end
  end

  describe "email and subscription must match" do
    let(:subscription) do
      subscription = mock_model(GroupSubscription)
      subscription.stub(:email).and_return("george@washington.com")
      subscription
    end

    it "should allow unsubscribes when the email and subscription match" do
      unsubscribe = GroupUnsubscribe.new(subscription: subscription, email: "george@washington.com")

      unsubscribe.valid?
      unsubscribe.errors[:email].should be_blank
    end

    it "should allow unsubscribes when the email has a different case" do
      unsubscribe = GroupUnsubscribe.new(subscription: subscription, email: "GEORge@WAShington.com")

      unsubscribe.valid?
      unsubscribe.errors[:email].should be_blank
    end

    it "should not allow unsubscribes when the email does not match" do
      unsubscribe = GroupUnsubscribe.new(subscription: subscription, email: "ben@franklin.com")

      unsubscribe.valid?
      unsubscribe.errors[:email].should_not be_blank
    end
  end

  context "a subscription and some signatures" do
    before(:each) do
      @organisation = Factory(:organisation)
      @group = Factory(:group, organisation: @organisation)
      @petition = Factory(:petition, organisation: @organisation, group: @group)
      @signature = Factory(:signature, petition: @petition)
      @subscription = GroupSubscription.create!(member: @signature.member, group: @group)
    end

    it "should unsubscribe the subscription and the group signature" do
      unsub = GroupUnsubscribe.new(subscription: @subscription, email: @signature.email)
      unsub.unsubscribe.should_not be_nil

      @signature.reload
      @signature.unsubscribe_at.should_not be_nil
      @subscription.unsubscribed_at.should_not be_nil
    end
  end
end
