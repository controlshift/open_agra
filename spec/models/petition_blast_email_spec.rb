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

describe PetitionBlastEmail do
  before(:each) do
    @blast = PetitionBlastEmail.new
  end

  subject { @blast }
  
  it_behaves_like BlastEmail
  it { should_not allow_value('Not sure what to write? There are templates on the bottom half of the page that you can use').for(:body)}

  describe "#awaiting_moderation" do
    before :each do
      @org = Factory(:organisation)
      @petition = Factory(:petition, :organisation => @org)
    end

    def email_with_moderation_status(moderation_status)
      create(:petition_blast_email, moderation_status: moderation_status, petition: @petition, moderation_reason: 'foo', organisation: @org)
    end

    specify { PetitionBlastEmail.awaiting_moderation(@org).should_not include email_with_moderation_status('approved') }
    specify { PetitionBlastEmail.awaiting_moderation(@org).should_not include email_with_moderation_status('inappropriate') }

    specify { PetitionBlastEmail.awaiting_moderation(@org).should include email_with_moderation_status('pending') }

    it "should return petitions that belongs to own organisation" do
      email_self = Factory(:petition_blast_email, petition: @petition, moderation_status: 'pending', organisation: @org)
      email_other = Factory(:petition_blast_email, moderation_status: 'pending')

      PetitionBlastEmail.awaiting_moderation(@org).should include(email_self)
      PetitionBlastEmail.awaiting_moderation(@org).should_not include(email_other)
    end
  end


  describe "#send_test_to" do
    it "should sent test email to user" do
      @mailer = mock
      CampaignerMailer.stub(:email_supporters) {@mailer}
      @mailer.should_receive(:deliver)
      CampaignerMailer.should_receive(:email_supporters).with(subject, [subject.from_address], nil)
    
      subject.send_test_email
    end
  end
  
  describe "#send_to_all" do
    let(:petition) { Factory(:petition) }

    it "should schedule blast email job" do
      @blast = Factory(:petition_blast_email, petition: petition)
      Factory :signature, petition: petition, unsubscribe_at: nil, join_organisation: true
      Sidekiq::Worker.clear_all
      @blast.send_to_all
      Sidekiq::Worker.jobs.size.should == 1
    end

    context 'threshold of 3 emails per week' do

      it "should not send blast if there have already been 3 emails which are either pending or approved" do
        3.times {
          blast = Factory(:petition_blast_email, moderation_status: 'pending', petition: petition)
          blast.valid?.should be_true
        }

        last_blast = Factory.build(:petition_blast_email, petition: petition)
        last_blast.valid?.should be_false
        last_blast.errors[:petition_id].should include("can have a maximum of three emails in a week.")
      end

      it 'should not count emails which have been marked as inappropriate ' do
        4.times do
          blast = Factory(:inappropriate_petition_blast_email, petition: petition)
        end
        last_blast = Factory.build(:petition_blast_email, petition: petition)
        last_blast.valid?.should be_true
      end
    end
  end

  describe "#recipient_count" do
    it "should set the recipient count" do
      petition = Factory(:petition)
      2.times do
        Factory(:signature, petition: petition, join_organisation: true)
      end
      blast = Factory.build(:petition_blast_email, petition: petition)
      blast.save
      blast.recipient_count.should == 2
    end
  end
end
