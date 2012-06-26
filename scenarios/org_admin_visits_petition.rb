require File.dirname(__FILE__) + '/scenario_helper.rb'

include LoginHelper
include PetitionHelper

describe "Org admin visits a petition'", type: :request, nip: true do
  before(:each) do
    @admin = Factory(:org_admin, organisation: @current_organisation)
    @user = Factory(:user, organisation: @admin.organisation)
    @different_organisation_user = Factory(:user)
    @petition = Factory(:petition, user: @user, organisation: @user.organisation)
    @different_organisation_petition = Factory(:petition, user: @different_organisation_user,
                                               organisation: @different_organisation_user.organisation)
    log_in(@admin.email, "onlyusknowit")
  end

  it "should show petition details from the same organisation" do
    visit petition_path(@petition)
    
    page.should have_content(@user.email)
    page.should have_content(@user.phone_number)
    
    page.should have_link "(Manage the petition)"
  end
  
  it "should not show petition details from a different organisation" do
    visit petition_path(@different_organisation_petition)
    
    page.should_not have_content(@user.email)
    page.should_not have_content(@user.phone_number)
    
    page.should_not have_link "(Manage the petition)"
  end
end
