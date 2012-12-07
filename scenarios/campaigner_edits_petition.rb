require File.dirname(__FILE__) + '/scenario_helper.rb'

include LoginHelper
include PetitionHelper
include CategoryHelper
include EmailHelper


describe "Campaigner edits petition from the manage page", type: :request do

  before(:each) do
    # create a category
    Factory(:category, name: 'Human Right', organisation: @current_organisation)

    # create a petition
    Factory(:user, email: 'email@test.com', organisation: @current_organisation)
    Factory(:petition, title: 'Save The Whales', slug: 'save-the-whales', organisation: @current_organisation,
            user: User.find_by_email('email@test.com'), launched: true, admin_status: 'good'  )
  end

  specify "edit a petition from the manage page" do
    reset_mailer
    log_in
    visit petition_manage_path("save-the-whales")
    click_on "Edit"
    
    edit_petition("save-the-whales", "Changed save the whales", "changed who", "changed what", "changed why", "changed delivery details")
    check 'Human Right'
    click_on 'Save'
    
    page.should have_content("The petition has been successfully updated!")

    page.should have_css("h1", text: "Changed save the whales")
    page.should have_content("changed who")
    page.should have_css(".what", text: "changed what")
    page.should have_css(".why", text: "changed why")
    page.find(".petition-image img")[:src].should match "white.jpg"
    page.should have_content "Human Right"

    # editing the content, should put the petition back in the moderation queue.
    Petition.find_by_slug('save-the-whales').admin_status.should == :edited
    open_last_email
    current_email.subject.should == 'An edited petition needs to be moderated'
  end
  
  specify "change 'Allow supporters to contact me' on settings menu", js: true do
    reset_mailer
    log_in
    visit petition_manage_path("save-the-whales")

    find("#petition_campaigner_contactable").should be_checked
    
    uncheck 'Supporters can contact me'
    
    click_on "View"
    page.should_not have_css("#view_contact_user_form")

    # toggling contactable should not count as editing the petition.
    Petition.find_by_slug('save-the-whales').admin_status.should == :good
    all_emails.should be_empty
  end
end
