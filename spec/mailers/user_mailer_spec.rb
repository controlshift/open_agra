require 'spec_helper'

describe UserMailer do
  before :each do
    @campaigner = Factory.build(:user)
    @organisation = Factory.create(:organisation)
    @petition = Factory(:petition, user: @campaigner, organisation: @organisation)
    @contact_email = Factory.build(:email)
  end
  
  describe "#contact_campaigner" do
    before :each do
      @contact_email.to_address = @campaigner.email
    end

    it "should send email to campaigner in a proper format" do
      email = UserMailer.contact_campaigner(@petition, @contact_email).deliver
      check_email_for_supporter email
    end

    def check_email_for_supporter(email)
      ActionMailer::Base.deliveries.should_not be_empty
      email.to.should == [@contact_email.to_address]
      email.from.should == [@contact_email.from_address]
      email.body.should include(@contact_email.content)
      email.body.should include("Below is a message about your petition")
      email.subject.should == "Message about your petition: " + @contact_email.subject
    end
  end
  
  describe "#contact_admin" do
    context "as a campaigner" do
      it "should send email to admin in case the petition is marked as inappropriate" do
        email = UserMailer.contact_admin(@petition, @contact_email).deliver
        check_email(email)
      end
    end
    
    def check_email(email)
      ActionMailer::Base.deliveries.should_not be_empty
      email.to.should == [@contact_email.to_address]
      email.from.should == [@contact_email.from_address]
      email.body.should include(@contact_email.content)
      email.body.should include("Below is a reply from an inappropriate petition")
      email.body.should include(@petition.title)
      email.body.should include(petition_url(@petition, host: @organisation.host))
      email.subject.should == "Reply from an inappropriate petition: " + @contact_email.subject
    end
  end
  
  describe "devise mailer" do
    before :each do
      @organisation = Factory(:organisation)
      @user = Factory(:user, organisation: @organisation)
      ActionMailer::Base.should_receive(:set_default_host).with(@organisation.host)
    end
    
    it "should send confirmation email" do
      mail = @user.devise_mailer.confirmation_instructions(@user).deliver
      mail.header['From'].to_s.should == "#{@organisation.name} <#{@organisation.contact_email}>"
    end
    
    it "should send reset password email" do
      mail = @user.devise_mailer.reset_password_instructions(@user).deliver
      mail.header['From'].to_s.should == "#{@organisation.name} <#{@organisation.contact_email}>"
    end
  end
end
