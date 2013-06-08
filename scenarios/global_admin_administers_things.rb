require File.dirname(__FILE__) + '/scenario_helper.rb'

include LoginHelper
include PetitionHelper

describe "petition admin", type: :request, nip: true, js: true do
  before(:each) do
    @admin = Factory(:admin, organisation: @current_organisation)
    @user = Factory(:user, organisation: @admin.organisation)
    @petition = Factory(:petition, organisation: @admin.organisation, user: @user)
    @petition.index!
    log_in(@admin.email, "onlyusknowit")
    click_on "Global Admin"
    click_on "Petitions"
  end

  it "search petitions and edit one" do
    fill_in "query", with: @petition.title
    click_on "admin-search-btn"
    within("#petitions") do
      wait_until(5) do
        page.has_content?(@petition.title)
      end
    end
  end
end

describe "user admin", type: :request, nip: true, js: true do
  before(:each) do
    @admin = Factory(:admin, organisation: @current_organisation)
    @user = Factory(:user, organisation: @admin.organisation)
  end

  it "search for a user, make them an admin" do
    log_in(@admin.email, "onlyusknowit")
    click_on "Global Admin"
    click_on "Users"
    fill_in "email", with: @user.email
    click_on "search-btn"

    page.should have_content "Edit #{@user.email}"


    check "user_admin" #makes this person an admin
    click_on "Save"

    page.should have_content "#{@user.email} saved."

    fill_in "email", with: @user.email
    click_on "search-btn"

    page.should have_content "Edit #{@user.email}"
    page.should have_checked_field("user_admin")
  end

  it "views list of users and can click one to edit it" do
    log_in(@admin.email, "onlyusknowit")
    click_on "Global Admin"
    click_on "Users"
    click_on @user.email
    fill_in "First name", with: "Changed Name"
    click_on "Save"
    page.should have_content("saved")
  end
end

describe "administer organisations", type: :request, nip: true do
  before(:each) do
    @admin = Factory(:admin, organisation: @current_organisation)
  end

  it "create an org, and then edit it's name" do
    log_in(@admin.email, "onlyusknowit")
    click_on "Global Admin"
    click_on "Orgs"
    click_on "New Org"

    fill_in "organisation_name", with: "Hope and Change"
    fill_in "organisation_slug", with: "hope"
    fill_in "organisation_host", with: "www.hopeandchange.com"
    fill_in "organisation_contact_email", with: "hopeandchange@email.com"
    fill_in "organisation_admin_email", with: "admin@email.com"
    fill_in "organisation_sendgrid_username" , with: "ausername"
    fill_in "organisation_sendgrid_password" , with: "apassword"

    click_on "Save"

    page.should have_content "Hope and Change"

    click_on "Hope and Change"

    page.should have_content "Edit"

    fill_in "organisation_name", with: "Fear and Stagnation"
    fill_in "organisation_slug", with: "fear"
    fill_in "organisation_host", with: "www.fearandstagnation.com"
    fill_in "organisation_contact_email", with: "fearandstagnation@email.com"
    fill_in "organisation_admin_email", with: "administrator@email.com"
    fill_in "organisation_sendgrid_username" , with: "ausername"
    fill_in "organisation_sendgrid_password" , with: "apassword"

    click_on "Save"

    page.should have_content "Fear and Stagnation"
    page.should have_content "fear"
    page.should have_content "www.fearandstagnation.com"
  end
  
end
