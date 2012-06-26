require File.dirname(__FILE__) + '/scenario_helper.rb'

include LoginHelper
include PetitionHelper

describe "Campaigner visits a petition'", :type => :request do
  before(:each) do
    @user = Factory(:user, organisation: @current_organisation)
    @petition = Factory(:petition, user: @user, organisation: @current_organisation)
    Factory(:campaign_admin, user: @user, petition: @petition, invitation_email: @user.email)
    @another_petition = Factory(:petition, user: @user, organisation: @current_organisation)
    log_in(@user.email)
  end

  it "should not see campaigner's contact information" do
    visit petition_path(@petition)
    page.should_not have_content(@user.email)
    page.should_not have_content(@user.phone_number)

    visit petition_path(@another_petition)
    page.should_not have_content(@user.email)
    page.should_not have_content(@user.phone_number)
  end
  
  context "petition is marked as inappropriate" do
    it "should see warning message and link to manage page" do
      @petition.update_attribute(:admin_status, :inappropriate)
      visit petition_path(@petition)

      page.should have_content "We've disabled this petition because we found a problem with it's content."
      page.should have_link "Fix This Problem"
    end
  end
end
