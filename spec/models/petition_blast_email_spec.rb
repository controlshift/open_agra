# == Schema Information
#
# Table name: petition_blast_emails
#
#  id                :integer         not null, primary key
#  petition_id       :integer
#  from_name         :string(255)     not null
#  from_address      :string(255)     not null
#  subject           :string(255)     not null
#  body              :text            not null
#  delayed_job_id    :integer
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#  recipient_count   :integer
#  moderation_status :string(255)     default("pending")
#  delivery_status   :string(255)     default("pending")
#  moderated_at      :datetime
#  moderation_reason :string(255)
#

require 'spec_helper'

describe PetitionBlastEmail do
  before(:each) do
    @blast = PetitionBlastEmail.new
  end

  subject { @blast }
  
  it { should validate_presence_of(:from_name) }
  it { should validate_presence_of(:from_address) }
  it { should validate_presence_of(:subject) }
  it { should validate_presence_of(:body) }
  
  it { should ensure_length_of(:from_name).is_at_most(100) }
  it { should ensure_length_of(:subject).is_at_most(255) }
  
  it { should allow_mass_assignment_of(:from_name) }
  it { should allow_mass_assignment_of(:from_address) }
  it { should allow_mass_assignment_of(:subject) }
  it { should allow_mass_assignment_of(:body) }
  
  it { should allow_value('ABCDEFGHIJKLMNOPQRSTUVWXYZ').for(:from_name) }
  it { should allow_value("abcdefghijklmnopqrstuvwxyz1234567890- '").for(:from_name) }
  it { should_not allow_value(',<.>/?;:"[{}]"~!@#$%^&*()_=+ ').for(:from_name) }
  it { should_not allow_value('Not sure what to write? There are templates on the bottom half of the page that you can use').for(:body)}
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

  describe "#awaiting_moderation" do
    before :each do
      @org = Factory(:organisation)
      @petition = Factory(:petition, :organisation => @org)
    end

    def email_with_moderation_status(moderation_status)
      Factory(:petition_blast_email, moderation_status: moderation_status, petition: @petition, moderation_reason: 'foo')
    end

    specify { PetitionBlastEmail.awaiting_moderation(@org).should_not include email_with_moderation_status('approved') }
    specify { PetitionBlastEmail.awaiting_moderation(@org).should_not include email_with_moderation_status('inappropriate') }

    specify { PetitionBlastEmail.awaiting_moderation(@org).should include email_with_moderation_status('pending') }

    it "should return petitions that belongs to own organisation" do
      email_self = Factory(:petition_blast_email, petition: @petition, moderation_status: 'pending')
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
      
      job_handle = mock
      job_handle.should_receive(:id).and_return(12345)
      Delayed::Job.should_receive(:enqueue).with(kind_of(Jobs::BlastEmailJob)).and_return(job_handle)
      @blast.send_to_all
      @blast.delayed_job_id.should == 12345
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
