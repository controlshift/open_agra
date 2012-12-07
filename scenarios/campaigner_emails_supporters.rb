require File.dirname(__FILE__) + "/scenario_helper.rb"

include LoginHelper
include PetitionHelper
include EmailHelper

describe "Campaigner sends email to supporter", type: :request do

  before :each do
    register
    create_petition("Save the Whales")
    click_on "launch-petition"
    visit new_petition_email_path("save-the-whales")
    stick_on_page = page.current_path
    click_on "Email me confirmation instructions"

    page.current_path.should == stick_on_page
    open_last_email_for('email@test.com')
    click_email_link_matching(/confirm/)

    click_on 'First Last'
    click_link "manage-email"
  end

  it "sends email to supporter", js: true do
    # write subject
    fill_in "Subject", with: "Test Subject"
    within_frame "petition_blast_email_body_ifr" do
      find("#tinymce").text.should_not be_nil
    end

    # select template
    click_on "delivery-anchor"
    find("#delivery").should be_visible

    click_on "share-on-social-media-anchor"
    click_on "Apply"

    expected_content = find("#share-on-social-media").text
    find("#share-on-social-media").should be_visible
    find("#delivery").should_not be_visible

    within_frame "petition_blast_email_body_ifr" do
     find("#tinymce").text.should == expected_content
    end
    # send test email
    click_on "Send test email to myself"

    page.current_path.should == new_petition_email_path("save-the-whales")
    page.should have_content "The test email has been sent."

    #verify he received email
    open_last_email
    current_email.subject.should == "Test Subject"

    # send email to supporter
    page.evaluate_script('window.confirm = function() { return true; }')
    click_on "Send"

    page.current_path.should == petition_manage_path("save-the-whales")
    page.should have_content "Your email has been sent to an administrator for approval."

    open_last_email
    current_email.subject.should include "An email needs to be moderated"
  end
end
