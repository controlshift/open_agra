require File.dirname(__FILE__) + '/scenario_helper.rb'

include LoginHelper
include PetitionHelper
include CategoryHelper

describe "Campaigner edits petition from the manage page", type: :request do

  before(:each) do
    # create a category
    @org_admin = Factory(:org_admin, organisation: @current_organisation)
    log_in(@org_admin.email, 'onlyusknowit')
    add_new_category 'Human Right'
    log_out
    
    # create a petition
    register
    create_petition('Save the Whales')
    click_on "launch-petition"
    log_out
  end

  it "should be able to edit a petition from the manage page" do
    log_in
    visit petition_manage_path("save-the-whales")
    click_on "Edit Petition"
    
    edit_petition("save-the-whales", "Changed save the whales", "changed who", "changed what", "changed why",
                  "changed delivery details", false)
    check 'Human Right'
    click_on 'Save'
    
    page.should have_content("The petition has been successfully updated!")

    click_on "View the petition"
    page.should have_css("h1", text: "Changed save the whales")
    page.should have_content("changed who")
    page.should have_css(".what", text: "changed what")
    page.should have_css(".why", text: "changed why")
    page.should_not have_css("#view_contact_user_form")
    page.find(".petition-image img")[:src].should match "white.jpg"
    page.should have_content "Human Right"
  end
end
