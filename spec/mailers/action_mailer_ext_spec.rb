require 'spec_helper'

include ActionMailer

class DummyMailer < ActionMailer::Base
  def send_mail(organisation)
    mail(subject: "dummy test", from:"from@gmail.com", to: "to@gmail.com", organisation: organisation)
  end
end

describe DummyMailer do
  describe "with an organisation" do
    let (:organisation) { Factory(:organisation) }


    it "should return a message object" do
      DummyMailer.send_mail(organisation).deliver.should be_kind_of Mail::Message
    end

    it "should set up sendgrid username and password" do
      DummyMailer.send_mail(organisation).deliver
      ActionMailer::Base.smtp_settings[:user_name].should == organisation.sendgrid_username
      ActionMailer::Base.smtp_settings[:password].should == organisation.sendgrid_password
    end
  end
end
