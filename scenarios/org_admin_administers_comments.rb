require File.dirname(__FILE__) + '/scenario_helper.rb'

include LoginHelper

describe "As Org admin", type: :request do
  before(:each) do
    @user = Factory(:user, organisation: @current_organisation)
    @petition = Factory(:petition, title: 'test_petition', user: @user, organisation: @current_organisation)
    @signature_for_flagged_comment = Factory(:signature, petition: @petition)
    @flagged_comment =Factory(:comment, :text => "this is a test flagged comment", :signature => @signature_for_flagged_comment, flagged_at: Time.now)
    @signature_for_non_flagged_comment = Factory(:signature, petition: @petition)
    @comment =Factory(:comment, :text => "a non flagged comment", :signature => @signature_for_non_flagged_comment,:flagged_at => nil )
    @org_admin = Factory(:org_admin, organisation: @current_organisation)
    log_in(@org_admin.email, 'onlyusknowit')
  end

  it "views the flagged out comments", js: true do
    click_on "#{@current_organisation.name} Admin"
    click_on "all-flagged-comments"
    page.should have_content("Flagged Petition Comments")
    page.should have_content("this is a test flagged comment")
    page.should_not have_content("a non flagged comment")
  end

  it "manages the signatures for a petition", js: true do
    click_on "#{@current_organisation.name} Admin"
    click_on "all-petitions"

    page.should have_content("#{@current_organisation.name} Petitions")
    page.should have_content("test_petition")
    find(:xpath, "//table/tbody/tr[1]/td[1]/a").click
    page.should have_content("test_petition")
    click_on "Admin"
    page.should have_link('Manage Comments')
    click_on 'Manage Comments'
    page.should have_content("this is a test flagged comment")
    page.should have_content("a non flagged comment")
  end
end