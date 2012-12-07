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
    @petition = Factory(:petition, user: @user, organisation: @current_organisation)

    click_on "#{@current_organisation.name} Admin"
    click_on "all-petitions"
    click_on @user.full_name

    page.current_path.should ==  edit_org_user_path(@user)

    # should be able to redirect to user edit page from hot petition list
    Factory(:signature, petition: @petition)
    click_on "#{@current_organisation.name} Admin"
    click_on "Hot"
    click_on @user.full_name

    page.current_path.should ==  edit_org_user_path(@user)

    #views list of users and can click one to edit it
    click_on "manage-members"
    click_on @user.email
    page.current_path.should ==  org_member_path(@user.member)
    click_on "Edit User"

    fill_in "user_first_name", with: "Changed Name"
    check "user_org_admin" #makes this person an admin
    click_on "Save"
    page.should have_content("saved")

    @user.reload
    @user.first_name.should == "Changed Name"
  end
end
