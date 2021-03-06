require File.dirname(__FILE__) + "/scenario_helper.rb"

include LoginHelper
include PetitionHelper
include JobHelper

describe "Supporter visits petition", type: :request do
  context "without location" do
    before(:each) do
      create_launched_petition
    end

    it "and signs", js: true do
      view_petition_details
      signs_petition
      comments
      check_thank_you_page
    end

    it "and signs without javascript" do
      view_petition_details
      signs_petition
      check_thank_you_page
    end

    it "and flags with reason", js: true do
      flag_petition
    end

    it "and likes the comment", js: true do
      like_comment
    end

    it "or flags a comment", js: true do
      flag_comment
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
      page.should_not have_css ".local-campaign-detail .petition-map"

      page.should have_css('#view-contact-user-form')
      page.should_not have_content("email@test.com")
      page.should_not have_content("15147034040")

      page.should_not have_content "Administrative Tools"

    end

    def flag_petition
      visit petition_path("capybara-test-for-supporters")

      click_link 'flag-petition'
      fill_in 'flag-reason', with: 'some reason'
      click_link 'btn-flag'
      page.should have_content 'The petition has been flagged'

      #should not able to flag the same petition
      click_link 'flag-petition'
      fill_in 'flag-reason', with: 'some reason'
      click_link 'btn-flag'
      page.should have_content 'You have already flagged this petition'
    end

    def signs_petition
      sign_petition("capybara-test-for-supporters")
      should_notify_partner_org
    end

    def comments
      page.should have_content("Tell others why you signed")
      page.should have_button "Save"
      leave_a_comment("Great Job! Well Done")
      page.should have_content("Thank you for your comment")
      page.should have_content("Great Job! Well Done")
    end
      
    def like_comment
      visit petition_path("capybara-test-for-supporters")
      sign_petition("capybara-test-for-supporters")
      leave_a_comment("Great Job! Well Done")
      find(:xpath, "//ul/li[1]/div[3]/a[1]").click

      #should not be able to like the comment again
      find(:xpath, "//ul/li[1]/div[3]/a[1]").click
    end

    def flag_comment
      visit petition_path("capybara-test-for-supporters")
      sign_petition("capybara-test-for-supporters")
      leave_a_comment("Great Job! This is a test comment!")
      find(:xpath, "//ul/li[1]/div[3]/a[2]").click

      find('#flag-captcha-form').should be_visible
      fill_in 'captcha', with: 'TEST'
      click_on 'Submit'

      page.should_not have_content("Great Job! This is a test comment!")
    end

    def check_thank_you_page
      page.should have_selector("a.share.email")
      send_an_email_link = find("#view_email_template")
      send_an_email_link["href"].should == "#email_template"
      send_an_email_link.click

      page.should have_content("Send an email")
    end

    def contact_campaigner
      visit petition_path("capybara-test-for-supporters")

      find("#view-contact-user-form").click

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
        find_field("signature_postcode").value.should == "2055"
      end
    end
  end

  context "with location" do
    it "should display petition location map" do
      petition = create(:petition_with_location, title: "petition title", organisation: @current_organisation)
      visit petition_path(petition)

      page.should have_css ".title:contains('petition title')"
      page.should have_css ".petition-box .petition-map"
    end
  end
end
