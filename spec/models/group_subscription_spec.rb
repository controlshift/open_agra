# == Schema Information
#
# Table name: group_subscriptions
#
#  id              :integer         not null, primary key
#  group_id        :integer
#  member_id       :integer
#  unsubscribed_at :datetime
#  token           :string(255)
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#

require 'spec_helper'

describe GroupSubscription do
  let(:organisation) { Factory(:organisation)}
  let(:group) { Factory(:group, organisation: organisation) }
  let(:member) { Factory(:member, organisation: organisation) }

  it { should belong_to :member }
  it { should belong_to :group }
  it { should validate_presence_of(:member_id)}
  it { should validate_presence_of(:group_id)}

  describe "tokens" do
    it "should have token generated after save" do
      subscription = GroupSubscription.new(member: member, group: group)
      subscription.token.should be_nil
      subscription.save!
      subscription.token.should_not be_nil
    end
  end

  describe ".subscribe!" do
    it "should create a subscription where none exists" do
      subscription = GroupSubscription.subscribe!(member, group)
      subscription.should_not be_nil
      subscription.should be_a(GroupSubscription)
    end

    context "with an existing GroupSubscription" do
      before(:each) do
        @subscription = GroupSubscription.create!(member: member, group: group)
      end

      it "should use the existing subscription if present" do
        GroupSubscription.subscribe!(member, group).should == @subscription
      end
    end
  end

  describe "#unsubscribed?" do
    it "should be subscribed if nil" do
      subscription = GroupSubscription.new(member: member, group: group)
      subscription.unsubscribed?.should be_false
    end

    it "should be unsubscribed if present" do
      subscription = GroupSubscription.new(member: member, group: group, unsubscribed_at: Time.now)
      subscription.unsubscribed?.should be_true
    end
  end

  describe "#resubscribe!" do
    it "should set the unsubscribed_at to nil" do
      subscription = GroupSubscription.subscribe!(member, group)
      subscription.unsubscribe!
      subscription.unsubscribed_at.should_not be_nil
      subscription.resubscribe!
      subscription.unsubscribed_at.should be_nil
    end
  end

  describe "#unsubscribe!" do
    it "should set unsubscribed_at" do
      subscription = GroupSubscription.subscribe!(member, group)
      subscription.unsubscribe!
      subscription.unsubscribed_at.should_not be_nil
      subscription.unsubscribed?.should be_true
    end
  end
end
