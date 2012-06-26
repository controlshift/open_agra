require File.dirname(__FILE__) + '/scenario_helper.rb'

include LoginHelper
include PetitionHelper

describe "Org admin edits user", type: :request, nip: true do
  before(:each) do
    @org_admin = Factory(:org_admin, organisation: @current_organisation)
    @user = Factory(:user, organisation: @org_admin.organisation)
    log_in(@org_admin.email, "onlyusknowit")
  end
  
  it "should be able to redirect to user edit page from org petition list" do
    Factory(:petition, user: @user, organisation: @current_organisation)

    click_on "#{@current_organisation.name} Admin"
    click_on "all-petitions"
    click_on @user.full_name

    page.current_path.should ==  edit_org_user_path(@user)
  end

  it "should be able to redirect to user edit page from hot petition list" do
    Factory(:signature, petition: Factory(:petition, user: @user, organisation: @current_organisation))
    click_on "#{@current_organisation.name} Admin"
    click_on "Hot"
    click_on @user.full_name

    page.current_path.should ==  edit_org_user_path(@user)
  end

  it 'views list of users and can click one to edit it' do
    click_on "#{@current_organisation.name} Admin"
    click_on "manage-users"
    click_on @user.email
    fill_in "First name", with: "Changed Name"
    click_on "Save"
    page.should have_content("saved")
  end
  
  it 'search for a user, make them an org admin', js: true do
    click_on "#{@current_organisation.name} Admin"
    click_on "manage-users"
    fill_in 'email', with: @user.email
    click_on "search-btn"
  
    page.should have_content "Edit #{@user.email}"
  
  
    check "user_org_admin" #makes this person an admin
    click_on "Save"

    page.should have_content "#{@user.email} saved."
  
    fill_in 'email', with: @user.email
    click_on "search-btn"
  
    page.should have_content "Edit #{@user.email}"
    page.should have_checked_field('user_org_admin')      
  end
end
