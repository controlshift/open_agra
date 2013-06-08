require File.dirname(__FILE__) + '/scenario_helper.rb'

include LoginHelper
include PetitionHelper
include EmailHelper

describe "Supporter cancels signature", :type => :request, :nip =>true do
  before(:each) do
    register
    create_petition('this is my petition', "Supporter", "For testing use", "Ensure system is working")
    click_on "launch-petition"
    log_out

    case ActionMailer::Base.delivery_method
      when :test then ActionMailer::Base.deliveries.clear
      when :cache then ActionMailer::Base.clear_cache
    end
  end

  it "should allow the signer to cancel their signature", js: true do
    sign_petition

    wait_until(2) do
      open_last_email_for('sean.ho@thoughtworks.com') != nil
    end
    
    open_last_email_for('sean.ho@thoughtworks.com')
    current_email.subject.should include("Thanks for signing")
    click_email_link_matching(/confirm_destroy/)

    page.should have_content("remove your signature")
    page.click_on "Remove Signature"
    page.should have_content "Your signature has been removed from the petition."
  end
end
