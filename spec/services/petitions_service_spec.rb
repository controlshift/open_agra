require 'spec_helper'

describe PetitionsService do
  include Shoulda::Matchers::ActionMailer
  include PetitionAttributesHelper

  subject{ PetitionsService.new }

  it "should respond to save" do
    subject.should respond_to(:save)
  end

  describe "thank the petition creator" do
    let(:petition) { mock }

    # this is a bit of an integration spec
    it "should send an email while creating a new petition" do
      @petition = Petition.new(attributes_for_petition(Factory.attributes_for(:petition)))
      @petition.organisation = Factory(:organisation)
      @petition.user = Factory(:user)
      delayed_job = mock()
      CampaignerMailer.should_receive(:delay).and_return(delayed_job)
      delayed_job.should_receive(:thanks_for_creating).with(@petition)
      PetitionsService.new.save(@petition)
    end

    context "when callbacks should be triggered after creation" do
      before(:each) do
        @organisation = Factory(:organisation)
        @user = Factory(:user, organisation: @organisation)
        petition.stub(:user).and_return(@user)
        petition.stub(:new_record?).and_return(true)
        petition.stub(:organisation).and_return(@organisation)
      end

      it "should trigger notification callback after petition creation" do
        subject.should_receive(:send_creation_thank_you_and_schedule_launch_reminder).and_return(true)
        petition.stub(:slug) { 'some-slug' }
        petition.stub(:save).and_return(true)
        subject.save(petition)
      end
    end

    it "should not thank if save fails" do
      petition.stub(:new_record?).and_return(true)
      petition.stub(:user).and_return(user = mock())
      subject.should_not_receive(:send_creation_thank_you_and_schedule_launch_reminder)
      petition.should_receive(:save).and_return(nil)
      subject.save(petition)
    end

    it "should not thank if user is not present" do
      CampaignerMailer.should_not_receive(:delay)
      promote_job = mock()
      Jobs::PromotePetitionJob.stub(:new).and_return(promote_job)
      promote_job.should_not_receive(:promote)
      subject.stub(:current_object).and_return(petition)
      petition.stub(:user).and_return(nil)
      subject.send_creation_thank_you_and_schedule_launch_reminder
    end

    it "should thank if the user is present" do
      subject.stub(:current_object).and_return(petition)
      petition.stub(:user).and_return(user = mock())
      petition.stub(:organisation).and_return(@organisation)
      petition.stub(:slug).and_return('slug')
      delay_job = mock()
      CampaignerMailer.should_receive(:delay).and_return(delay_job)
      delay_job.should_receive(:thanks_for_creating).with(petition)
      promote_job = mock()
      Jobs::PromotePetitionJob.stub(:new).and_return(promote_job)
      promote_job.should_receive(:promote).with(petition, :send_launch_kicker)

      subject.send_creation_thank_you_and_schedule_launch_reminder
    end
  end

  describe "#actions_after_petition_is_created_and_has_user" do
    let(:petition) { mock }

    before(:each) do
      @organisation = Factory(:organisation)
      @user = Factory(:user, organisation: @organisation)
      petition.stub(:user).and_return(@user)
      petition.stub(:new_record?).and_return(true)
      petition.stub(:organisation).and_return(@organisation)
    end

    it "should notify the organisation" do
      petition.stub(:slug) { 'some-slug' }
      petition.stub(:save).and_return(true)
      subject.stub(:current_object).and_return(petition)

      notifier = mock
      delayed_job = mock
      OrgNotifier.stub(:new) { notifier }
      notifier.should_receive(:delay) { delayed_job }
      delayed_job.should_receive(:notify_sign_up).with(organisation: petition.organisation, petition: petition, 
                                                       user_details: petition.user, role: 'creator')

      campaigner_mailer = mock()
      campaigner_mailer.should_receive(:thanks_for_creating)
      CampaignerMailer.should_receive(:delay) { campaigner_mailer }

      moderation_mailer = mock()
      moderation_mailer.should_receive(:notify_admin_of_new_petition)
      ModerationMailer.should_receive(:delay) { moderation_mailer }

      promote_job = mock()
      Jobs::PromotePetitionJob.stub(:new).and_return(promote_job)
      promote_job.should_receive(:promote).with(petition, :send_launch_kicker)


      subject.send(:actions_after_petition_is_created_and_has_user)
    end
  end
  
  describe "#notify_petition_being_edited_by_campaigner" do
    before :each do
      @petition = Factory(:petition, admin_status: :approved)
      subject.stub(:current_object) { @petition }
    end

    it "should notify the organisation if petition is edited" do
      moderation_mailer = mock
      moderation_mailer.should_receive(:notify_admin_of_edited_petition)
      ModerationMailer.should_receive(:delay) { moderation_mailer }

      @petition.title = "changed"
      
      subject.save(@petition)
      @petition.admin_status.should == :edited
    end
    
    it "should notify the organisation if petition is edited" do
      @petition.admin_reason = "test"
      @petition.admin_status = :inappropriate
      
      moderation_mailer = mock
      moderation_mailer.should_receive(:notify_admin_of_edited_petition)
      ModerationMailer.should_receive(:delay) { moderation_mailer }

      @petition.title = "changed"
      
      subject.save(@petition)
      @petition.admin_status.should == :edited_inappropriate
    end
    
    it "should not notify the organisation if nothing has been changed" do
      ModerationMailer.should_not_receive(:delay)

      subject.save(@petition)
      @petition.admin_status.should == :approved
    end

    it "should not notify the organisation if achievement has been changed" do
      ModerationMailer.should_not_receive(:delay)

      @petition.share_on_facebook = 1
      subject.save(@petition)

      @petition.admin_status.should == :approved
    end

    it "should not notify the organisation if person changes their contact setting" do
      ModerationMailer.should_not_receive(:delay)
      subject.update_attributes(@petition, {:campaigner_contactable => "false"})

      @petition.admin_status.should == :approved
    end
  end

  describe "petition, meet your maker" do
    it "should link up and send" do
      petition = Petition.new
      user = User.new
      petition.should_receive(:save!)

      delay_job_thanks = mock()
      delay_job_thanks.should_receive(:thanks_for_creating).with(petition)
      CampaignerMailer.should_receive(:delay).and_return(delay_job_thanks)
      promote_job = mock()
      Jobs::PromotePetitionJob.stub(:new).and_return(promote_job)
      promote_job.should_receive(:promote).with(petition, :send_launch_kicker)

      subject.link_petition_with_user!(petition, user)
    end
  end

  describe "#notify_petition_being_marked_as_inappropriate" do
    it "should not be trigger after create" do
      subject.should_not_receive(:notify_petition_being_marked_as_inappropriate)
      petition = Factory.build(:petition)
      subject.save(petition)
    end

    it "should be trigger after update" do
      subject.should_receive(:notify_petition_being_marked_as_inappropriate)
      petition = Factory(:petition)
      petition.admin_status = :approved
      CampaignerMailer.should_not_receive(:delay)
      subject.save(petition)
    end

    it "should notify campaigner after update if admin status is set to be inappropriate" do
      petition = Factory(:petition)

      petition.admin_status = :awesome
      subject.save(petition)
      Delayed::Job.count.should == 0

      petition.admin_status = :inappropriate
      petition.admin_reason = "it's inappropriate"
      subject.save(petition)
      Delayed::Job.count.should == 1
      Delayed::Job.last.handler.should match(/notify_petition_being_marked_as_inappropriate/i)
    end

    it "should not notify campaigner when updating a note field" do
      petition = Factory(:petition)

      petition.admin_status = :awesome
      subject.save(petition)

      petition.admin_notes = 'a note '
      CampaignerMailer.should_not_receive(:delay)
      subject.save(petition)
    end
  end

  describe "#link_petition_with_user!" do
    it "should not link petition with user if the petition has already has a user" do
      petition_owner = create(:user)
      petition = create(:petition, user: petition_owner)
      another_user = create(:user)

      subject.link_petition_with_user!(petition, another_user)

      petition.user.should == petition_owner
    end
  end
end
