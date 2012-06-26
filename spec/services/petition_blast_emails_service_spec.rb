require 'spec_helper'

describe PetitionBlastEmailsService do
  subject{ PetitionBlastEmailsService.new }

  describe "#send_email_to_supporters" do
    before :each do
      @delayed_job = mock
      ModerationMailer.stub(:delay) { @delayed_job }
    end
    
    it "should notify campaigner and send email to supporters if org admin approved the blast email" do
      email = PetitionBlastEmail.new
      email.stub(:new_record?).and_return(true)
      email.stub(:recipient_count).and_return(PetitionBlastEmail::RECIPIENT_MODERATION_LIMIT+1)
      email.stub(:ready_to_send?).and_return(true)
      email.should_receive(:send_to_all).and_return(true)
      email.should_receive(:save).and_return(true)
      @delayed_job.should_receive(:notify_campaigner_of_approval).with(email)
      subject.save(email)
    end

    it "should notify org admin if not yet ready to and pending approval" do
      email = PetitionBlastEmail.new
      email.stub(:new_record?).and_return(true)
      email.stub(:recipient_count).and_return(PetitionBlastEmail::RECIPIENT_MODERATION_LIMIT+1)
      email.stub(:ready_to_send?).and_return(false)
      email.should_not_receive(:send_to_all)
      email.should_receive(:save).and_return(true)
      @delayed_job.should_receive(:notify_admin_of_new_blast_email).with(email)
      subject.save(email)
    end
    
    it "should notify campaigner if org admin disapproved the blast email" do
      email = PetitionBlastEmail.new
      email.moderation_status = 'inappropriate'
      email.stub(:new_record?).and_return(true)
      email.stub(:recipient_count).and_return(PetitionBlastEmail::RECIPIENT_MODERATION_LIMIT+1)
      email.stub(:ready_to_send?).and_return(false)
      email.should_not_receive(:send_to_all)
      email.should_receive(:save).and_return(true)
      @delayed_job.should_receive(:notify_campaigner_of_rejection).with(email)
      subject.save(email)
    end
  end

  describe "#set_initial_moderation_status" do
    it "should send if below the limit" do
      email = PetitionBlastEmail.new
      email.stub(:new_record?).and_return(true)
      email.stub(:ready_to_send?).and_return(false)
      email.stub(:recipient_count).and_return(PetitionBlastEmail::RECIPIENT_MODERATION_LIMIT-1)
      email.should_receive(:moderation_status=).with('approved')
      email.should_receive(:save).and_return(true)
      subject.save(email)
    end

    it "should remain pending if above the limit" do
      email = PetitionBlastEmail.new
      email.stub(:ready_to_send?).and_return(false)
      email.stub(:new_record?).and_return(true)
      email.stub(:recipient_count).and_return(PetitionBlastEmail::RECIPIENT_MODERATION_LIMIT+1)
      email.should_not_receive(:moderation_status=).with('approved')
      email.should_receive(:save).and_return(true)
      subject.save(email)
    end
  end
end