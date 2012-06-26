require File.dirname(__FILE__) + '/scenario_helper.rb'

include LoginHelper
include PetitionHelper

describe "Org admin view moderation queue", type: :request, nip: true do
  before(:each) do
    @org_admin = Factory(:org_admin, organisation: @current_organisation)
    @user = Factory(:user, organisation: @org_admin.organisation)
    create_num_of_petitions_with_admin_status(:edited, 2)
    create_num_of_petitions_with_admin_status(:edited_inappropriate, 1)
    create_num_of_petitions_with_admin_status(:unreviewed, 1)
    create_num_of_petitions_with_admin_status(:approved, 1)

    log_in(@org_admin.email, "onlyusknowit")

    click_on "#{@current_organisation.name} Admin"
  end

  it "should show petitions need to be moderate" do
    click_on "Moderation"
    find("#num_of_petitions_to_moderate").should have_content(4)
    find("#num_of_edited_petitions").should have_content(3)
    find("#num_of_new_petitions").should have_content(1)
  end
end

def flag_petition_num_of_times(petition, num_of_times)
  num_of_times.times do
    Factory(:petition_flag, petition: petition)
  end
end

def create_petition_with_admin_status(admin_status)
  petition = Factory(:petition, user: @user, organisation: @user.organisation)
  petition.update_attribute(:admin_status, admin_status)
  petition
end

def create_num_of_petitions_with_admin_status(admin_status, num_of_times)
  num_of_times.times do
    create_petition_with_admin_status(admin_status)
  end
end

