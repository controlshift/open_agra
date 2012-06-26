require "spec_helper"

describe CampaignerMailer do
  before :each do
    @organisation = Factory(:organisation)
    @campaigner = Factory(:user, organisation: @organisation)
    @petition = Factory(:petition, user: @campaigner, organisation: @organisation)
  end

  context "a signature and blast email" do
    before(:each) do
      @signature = Factory(:signature, petition: @petition)
      @email = Factory(:petition_blast_email, petition: @petition)
    end

    it "should send mail to supporters" do
      email = CampaignerMailer.email_supporters(@email, [@signature.email], [@signature.token]).deliver
      check_email(email)
    end

    def check_email(email)
      json = JSON.parse(email.header['X-SMTPAPI'].value)
      json["to"].should == [@signature.email]
      json["sub"]["___token___"] == [unsubscribing_petition_signature_url(@petition, @signature.token)]
      email.from.should == [@email.from_address]
      email.subject.should == @email.subject
      email_content = email.body.to_s.chomp
      email_content.should include @email.body
    end

    it "should sanitize the email body" do
      javascript_string = "<script type=\"text/javascript\">$('.I am dangerous').click()</script>"
      sanitized_email_body = @email.body
      @email.update_attribute(:body, @email.body + javascript_string)
      email = CampaignerMailer.email_supporters(@email, [@signature.email], [@signature.token])

      email_content = email.body.to_s.chomp
      email_content.should_not include javascript_string
      email_content.should include sanitized_email_body
    end
  end

  it "should send thank you for creating a petition" do
    email = CampaignerMailer.thanks_for_creating(@petition)
    email.from.should == [@petition.organisation.contact_email]
    email.header['From'].to_s.should include @petition.organisation.name
    email.subject.should == "Thanks for creating the petition: #{@petition.title}"
    email.to.should == [@campaigner.email]
    email.body.should match(/Congratulations/)
  end

  it "should use the effort body content if available" do
    @petition.effort = Factory(:effort, :thanks_for_creating_email => 'foo bar', :organisation => @petition.organisation )
    email = CampaignerMailer.thanks_for_creating(@petition)
    email.body.should == 'foo bar'
  end

  it "should send email to notify campaigner their petition has marked as inappropriate" do
    @petition.admin_status = :inappropriate
    @petition.admin_reason = "It's bad. We don't like it."
    @petition.save!
    email = CampaignerMailer.notify_petition_being_marked_as_inappropriate(@petition)
    email.body.should include(@petition.admin_reason)
    email.to.should == [@petition.email]
  end

  it "should send share kicker email" do
    email = CampaignerMailer.send_share_kicker(@petition)
    email.to.should == [@petition.email]
    email.subject.should == 'Share with your friends'
  end
  
  it "should send email to notify campaigner of petition letter ready for download" do
    email = CampaignerMailer.notify_petition_letter_ready_for_download(@petition)
    email.from.should == [@petition.organisation.contact_email]
    email.header['From'].to_s.should include @petition.organisation.name
    email.to.should == [@campaigner.email]
    email.subject.should == 'Petition is ready to Deliver'
    email.body.should include "Download"
  end
end
