# == Schema Information
#
# Table name: blast_emails
#
#  id                :integer         not null, primary key
#  petition_id       :integer
#  from_name         :string(255)     not null
#  from_address      :string(255)     not null
#  subject           :string(255)     not null
#  body              :text            not null
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#  recipient_count   :integer
#  moderation_status :string(255)     default("pending")
#  delivery_status   :string(255)     default("pending")
#  moderated_at      :datetime
#  moderation_reason :text
#  type              :string(255)
#  group_id          :integer
#  organisation_id   :integer
#  target_recipients :string(255)
#

require 'spec_helper'

describe GroupBlastEmail do
  before(:each) do
    @blast = GroupBlastEmail.new
  end

  subject { @blast }

  it_behaves_like BlastEmail

  describe "#recipient_count" do
    it "should set the recipient count" do
      group = create(:group)
      member = create(:member, organisation:  group.organisation)
      subscription = GroupSubscription.create(member: member, group: group)
      blast = create(:group_blast_email, group: group)
      blast.recipient_count.should == 1
    end
  end

  context 'threshold of 3 emails per week' do

    it "should not send blast if there have already been 3 emails which are either pending or approved" do
      group = create(:group)
      3.times {
        blast = Factory(:group_blast_email, moderation_status: 'pending', group: group)
        blast.valid?.should be_true
      }

      last_blast = Factory.build(:group_blast_email, group: group)
      last_blast.valid?.should be_false
      last_blast.errors[:group_id].should include("can have a maximum of three emails in a week.")
    end

    it 'should not count emails which have been marked as inappropriate ' do
      group = create(:group)

      4.times do
        blast = Factory(:inappropriate_group_blast_email, group: group)
      end
      last_blast = Factory.build(:group_blast_email, group: group)
      last_blast.valid?.should be_true
    end
  end
end
