require "spec_helper"

describe PromotePetitionMailer do
  before :each do
    @organisation = Factory(:organisation)
    @petition = Factory(:petition, organisation: @organisation)
  end

  describe "#reminder_when_dormant" do
    specify { check_email(PromotePetitionMailer.reminder_when_dormant(@petition).deliver, @petition.title) }

    it "should include feedback link in the email if it exists" do
      @organisation.update_attribute(:campaigner_feedback_link, "http://forum.com")
      @petition.reload
      email = PromotePetitionMailer.reminder_when_dormant(@petition).deliver 
      email.body.should include "http://forum.com"
      email.body.should include "Post questions or ask"
    end

    it "should not include feedback text in the email if feedback link does not exist" do
      email =  PromotePetitionMailer.reminder_when_dormant(@petition).deliver
      email.body.should_not include "Post questions or ask for advice"
    end
    
  end
  
  describe "#encourage" do
    specify { check_email(PromotePetitionMailer.encourage(@petition).deliver, "Only 10 to go") }

    it "should include feedback link in the email if it exists" do
      @organisation.update_attribute(:campaigner_feedback_link, "http://forum.com")
      @petition.reload
      email = PromotePetitionMailer.encourage(@petition).deliver 
      email.body.should include "http://forum.com"
      email.body.should include "Do you have feedback"
    end

    it "should not include feedback text in the email if feedback link does not exist" do
      email =  PromotePetitionMailer.encourage(@petition).deliver
      email.body.should_not include "Do you have feedback"
    end
  end

  describe "achieved_signature_goal" do
    specify { check_email(PromotePetitionMailer.achieved_signature_goal(@petition).deliver,
                          "You did it - your petition just hit 100 signatures.") }
  end

  describe "send_launch_kicker" do
    specify { check_email(PromotePetitionMailer.send_launch_kicker(@petition).deliver,
                          'Get started on your petition') }
  end

  def check_email(email, subject)
    email.to.should == [@petition.email]
    email.from.should == [@petition.organisation.contact_email]
    email.header['From'].to_s.should include @petition.organisation.name
    email.subject.should == subject
  end

end
