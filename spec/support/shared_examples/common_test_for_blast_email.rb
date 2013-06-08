require 'spec_helper'

shared_examples_for BlastEmail do

  it { should validate_presence_of(:from_name) }
  it { should validate_presence_of(:from_address) }
  it { should validate_presence_of(:subject) }
  it { should validate_presence_of(:body) }

  it { should ensure_length_of(:from_name).is_at_most(200) }
  it { should ensure_length_of(:subject).is_at_most(255) }

  it { should allow_mass_assignment_of(:from_name) }
  it { should allow_mass_assignment_of(:from_address) }
  it { should allow_mass_assignment_of(:subject) }
  it { should allow_mass_assignment_of(:body) }

  it { should allow_value('foo bar').for(:body)}

  it "should combine email with name" do
    subject.from_name = 'George'
    subject.from_address = 'g@washington.com'
    subject.from.should == '"George" <g@washington.com>'
  end

  it "should ensure moderation_reason is not nil when email is set to inappropriate" do
    subject.moderation_status.should == 'pending'
    subject.valid?
    subject.errors[:moderation_reason].should be_empty

    subject.moderation_status = 'inappropriate'
    subject.valid?
    subject.errors[:moderation_reason].should_not be_empty
  end

  describe "#in_delivery?" do
    it "should not be if pending" do
      subject.delivery_status.should == 'pending'
      subject.in_delivery?.should be_false
    end

    it "should be if delivered" do
      subject.delivery_status = 'delivered'
      subject.in_delivery?.should be_true
    end

    it "should be if sending" do
      subject.delivery_status = 'sending'
      subject.in_delivery?.should be_true
    end
  end

  describe "#ready_to_send?" do
    it "should be ready if approved and pending" do
      subject.delivery_status = 'pending'
      subject.moderation_status = 'approved'
      subject.ready_to_send?.should be_true
    end

    it "should not be ready if not approved" do
      subject.delivery_status = 'pending'
      subject.moderation_status = 'inappropriate'
      subject.ready_to_send?.should be_false
    end

    it "should not be ready if already delivered" do
      subject.delivery_status = 'sending'
      subject.moderation_status = 'inappropriate'
      subject.ready_to_send?.should be_false
    end
  end

  describe "#available_to_moderate?" do
    it "should not let you mark approved emails" do
      subject.moderation_status = 'approved'
      subject.available_to_moderate?.should be_false
    end

    it "should let you mark pending emails" do
      subject.moderation_status = 'pending'
      subject.available_to_moderate?.should be_true
    end

    it "should not let you mark inappropriate emails" do
      subject.moderation_status = 'inappropriate'
      subject.available_to_moderate?.should be_false
    end
  end
end