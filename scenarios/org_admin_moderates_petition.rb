require File.dirname(__FILE__) + '/scenario_helper.rb'

include LoginHelper
include PetitionHelper

describe "Org admin moderates a petition", type: :request, nip: true do
  before(:each) do
    @admin = Factory(:org_admin, organisation: @current_organisation)
    @user = Factory(:user, organisation: @admin.organisation)
    @petition = Factory(:petition, user: @user, organisation: @user.organisation)
    @another_petition = Factory(:petition, user: @user, organisation: @user.organisation)
    log_in(@admin.email, "onlyusknowit")
  end
  
  it "should allow admin to add a note", js: true do
    visit petition_path(@petition)
    page.should have_content "Administrative Tools"
    page.should have_content "Notes"
    find("#notes-toggle").click
    fill_in("notes", with: 'this is a note here.')
    find("#btn-save-notes").click
    wait_until{ @petition.reload.admin_notes == 'this is a note here.' }

    page.should have_content "Your notes have been saved."
    page.current_path.should == petition_path(@petition)
  end

  it "should be able to moderate petition by status" do
    visit petition_path(@petition)
    page.should have_content "Administrative Tools"
    select "Approved", from: "petition_admin_status"
    find("input[value='Save & next petition']").click

    page.should have_content "Moderation status of previous petition is updated successfully."
    page.current_path.should == petition_path(@another_petition)

    select "Approved", from: "petition_admin_status"
    find("input[value='Save']").click
    page.current_path.should == petition_path(@another_petition)
  end

  it "should allow admin to input reason for inappropriate petition", js: true do
    visit petition_path(@petition)
    page.should have_content "Administrative Tools"
    find(".inappropriate-reason-popover").should_not be_visible

    select "Inappropriate", from: "petition_admin_status"
    find(".inappropriate-reason-popover").should be_visible
    fill_in("petition_admin_reason", with: "reason goes here.")

    click_on "Save & next petition"

    visit petition_path(@petition)
    find(".inappropriate-reason-popover").should be_visible
  end
 end
