require 'spec_helper'

describe Jobs::BlastEmailJob do
  before(:each) do
    @campaigner = Factory(:user)
    @petition = Factory(:petition, user: @campaigner)
    @email = Factory(:petition_blast_email, petition: @petition)
    @job = Jobs::BlastEmailJob.new(@email)
  end

  describe "#perform" do
    it "should perform sending blast email" do

      2.times { Factory(:signature, petition: @petition, join_organisation: true) }
      
      signatures = @petition.signatures.subscribed

      mailer_obj = mock()
      mailer_obj.stub(:deliver).and_return(true)

      CampaignerMailer.should_receive(:email_supporters).once.with(@email, signatures.map(&:email), signatures.map(&:token)).and_return(mailer_obj)

      @job.perform
    end

    it "should slice and send blast email in batches" do
      3.times { Factory(:signature, petition: @petition, join_organisation: true) }

      signatures = @petition.signatures.subscribed
      
      @job.stub(:email_batch_size).and_return(2)

      mailer_obj = mock()
      mailer_obj.stub(:deliver).and_return(true)

      CampaignerMailer.should_receive(:email_supporters).once.ordered.with(@email, signatures[0, 2].map(&:email), signatures[0,2].map(&:token)).and_return(mailer_obj)
      CampaignerMailer.should_receive(:email_supporters).once.ordered.with(@email, signatures.drop(2).map(&:email), signatures.drop(2).map(&:token)).and_return(mailer_obj)

      @job.perform
    end
    
    it "should notify organisation when error occurs during the sending" do
      2.times { Factory(:signature, petition: @petition, join_organisation: true) }
      signatures = @petition.signatures.subscribed
      mailer_exception_obj = mock()
      mailer_exception_obj.stub(:deliver).and_raise(Exception)
      
      mailer_obj = mock()
      mailer_obj.stub(:deliver).and_return(true)

      CampaignerMailer.should_receive(:email_supporters).once.ordered.with(@email, signatures.map(&:email), signatures.map(&:token)).and_return(mailer_exception_obj)
      ExceptionNotifier::Notifier.should_receive(:background_exception_notification)

      @job.perform
    end
  end
end
