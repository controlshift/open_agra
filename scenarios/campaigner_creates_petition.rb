require File.dirname(__FILE__) + '/scenario_helper.rb'

include LoginHelper
include PetitionHelper
include EmailHelper
include JobHelper
include CategoryHelper

describe "Campaigner creates petition", type: :request do

  context 'when user is logged in' do
    before(:each) do
      # create a category
      @org_admin = Factory(:org_admin, organisation: @current_organisation)
      log_in(@org_admin.email, 'onlyusknowit')
      add_new_category 'Category 1'
      add_new_category 'Category 2'
      add_new_category 'Category 3'
      log_out
      
      register
    end

    it "should go through the whole create petition process", nip: true, js: true do
      visit new_petition_path(:source => 'foo')
      fill_in_petition('No more pokies', 'who', 'what', 'why')
      click_on 'Save'

      # Hmmm... how does the petition look?
      should_notify_partner_org
      page.should have_css("div.launch")
      page.should have_content("No more pokies")

      # We made a mistake, go back and edit the petition
      click_link "Edit"
      page.should have_content("New Campaign")
      page.should have_css("#cancel-edit-btn")

      petition_title = find("#petition_title")
      petition_title.value.should == "No more pokies"
      fill_in "petition_title", with: "Lets stop poking"
      click_on "Save"

      # great looks good now.
      page.should have_css("div.launch")
      page.should have_content("Lets stop poking")

      # lets add an image.
      attach_file :image, Rails.root.join("scenarios/fixtures/white.jpg")

      page.find("#status-text").should have_content "Image uploaded!"
      page.find(".petition-image img")[:src].should match "white.jpg"

      petition = Petition.last

      wait_until { petition.reload.image.present? }
      petition.image_file_name.should match "white.jpg"


      # select some categories
      click_on "Select Categories..."
      page.should have_selector('.modal-header', visible: true)
      check "Category 2"
      check "Category 3"
      click_on "Save"

      wait_until { petition.categories(true).any? }

      categories = petition.categories.collect{|c| c.name}
      categories.should == ["Category 2", "Category 3"]

      # and launch it
      click_on "launch-petition"

      # check that all the pieces have been appropriately saved.
      open_last_email_for('email@test.com')
      current_email.subject.should match(/Thanks for creating the petition/)
      current_email.from.first.should == @current_organisation.contact_email

      page.current_path.should == petition_manage_path('no-more-pokies')

      # verify that everything was saved properly.
      petition = Petition.last
      petition.title.should == 'Lets stop poking'
      petition.who.should == 'who'
      petition.what.should == 'what'
      petition.why.should == 'why'
      petition.source.should == 'foo'
      petition.image_file_name.should == 'white.jpg'
    end
  end
  
  context 'when user is not logged in' do
    it 'should create petition for new campaigner', nip: true do
      email = "email2@test.com"
      add_to_whitelist(email)
      create_petition("No more pokies")
      fill_and_submit_registration_form("Johnny", "Depp", email, "abc123", "1234567", '2010', show_chevrons: true)

      page.should have_content('No more pokies')

      #check to see if we told our parent org.
      user = User.find_by_email(email)
      user.join_organisation.should be_true
      should_notify_partner_org

      # should be able to log out and create more petitions as this new user.
      log_out

      create_petition("No more pokies")
      fill_and_submit_login_form("email2@test.com", "abc123", show_chevrons: true)

      page.should have_css('.launch .chevron')
      page.should have_content('No more pokies')
    end
  end
end
