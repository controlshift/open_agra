require File.dirname(__FILE__) + "/scenario_helper.rb"

include LoginHelper
include PetitionHelper
include EmailHelper

describe "Campaigner confirms his email", type: :request do

  before :each do
    register
    create_petition("Save the Whales")
    click_on "launch-petition"
  end

  it "confirms his email when he wants to email his supporters" do
    visit new_petition_email_path("save-the-whales")
    stick_on_page = page.current_path

    # Need to confirm his email
    click_on "Email me confirmation instructions"
    page.current_path.should == stick_on_page
    page.should have_content("receive an email with instructions")

    # Should receive a confirmation email
    open_last_email_for('email@test.com')
    click_email_link_matching(/confirm/)
    
    # Should go back to the email supporter page with a message
    page.should have_content("email was successfully confirmed")
    page.should have_content("Email supporters") 
  end
end
