require File.dirname(__FILE__) + "/scenario_helper.rb"

include LoginHelper
include PetitionHelper
include JobHelper

describe "Supporter visits petition", type: :request do
  
  before(:each) do
    create_launched_petition
  end

  it "and signs", js: true do
    view_petition_details
    signs_petition
    check_thank_you_page
  end

  it "and signs without javascript" do
    view_petition_details
    signs_petition
    check_thank_you_page
  end

  it "and flags" do
    flag_petition
  end

  context "contacting campaigner", js: :true do
    it "and contacts campaigner" do
      contact_campaigner     
    end
  end

  context "supporter is a campaigner" do
    it "and signs" do
      sign_form_already_filled
    end

  end

  def create_launched_petition
    register("Fred", "Lastname", "email@test.com", "onlyusknowit", "15147034040")
    create_petition "Capybara Test For Supporters", "Supporter", "For testing use", "Ensure system is working"
    click_on "launch-petition"
    log_out
  end

  def view_petition_details
    page.should_not have_link "Start a petition"

    visit petition_path("capybara-test-for-supporters")

    page.should have_content("Capybara Test For Supporters")
    page.should have_content("To: Supporter")
    page.should have_content("For testing use")
    page.should have_content("Ensure system is working")
    page.should have_content("Fred")

    page.should have_css('#view_contact_user_form')
    page.should_not have_content("email@test.com")
    page.should_not have_content("15147034040")

    page.should_not have_content "Administrative Tools"

  end

  def flag_petition    
    visit petition_path("capybara-test-for-supporters")

    click_on "Flag this petition for review"
    page.should have_content("The petition has been flagged")

    #should not able to flag the same petition
    click_on "Flag this petition for review"
    page.should have_content("You have already flagged this petition")
  end

  
  def signs_petition
    sign_petition("capybara-test-for-supporters")
    should_notify_partner_org
  end

  def check_thank_you_page
    page.should have_selector("a.share.email")
    find("a.share.twitter")["href"].should match(/https\:\/\/twitter.com\/intent\/tweet\?url\=http\:\/\/.+\/petitions\/capybara-test-for-supporters&text\=/)
    find("a.share.facebook")["data-href"].should include "http://www.facebook.com/sharer.php?u=http"
    find("a.share.facebook")["data-href"].should include "capybara-test-for-supporters"
    send_an_email_link = find("#view_email_template")
    send_an_email_link["href"].should == "#email_template"
    send_an_email_link.click

    page.should have_content("Subject of email")
    page.should have_content("Body of email")
  end

  def contact_campaigner 
    visit petition_path("capybara-test-for-supporters")

    find("#view_contact_user_form").click

    find('#contact_user_form').should be_visible
    fill_in 'email_from_name', with: "Charlie"
    fill_in 'email_from_address', with: "charlie@gmail.com"
    fill_in 'email_subject', with: "Save oranges"
    fill_in 'email_content', with: "I love oranges"

    find("#btn-send").click
    current_path.should == petition_path("capybara-test-for-supporters")
    page.should have_content("Your message has been sent.")
  end

  def sign_form_already_filled
      register("James", "Bond", "email2@test.com", "abc123", "12345678", "2055")
      visit petition_path("capybara-test-for-supporters")

      within("#new_signature") do
        find_field("First name").value.should == "James"
        find_field("Last name").value.should == "Bond"
        find_field("Email").value.should == "email2@test.com"
        find_field("Phone Number").value.should == "12345678"
        find_field("Postcode").value.should == "2055"
    end
  end
end
