require File.dirname(__FILE__) + '/scenario_helper.rb'

include LoginHelper
include PetitionHelper


describe "User flag petition", type: :request, js: true do
  it "should flag petition with reason" do
    create_inappropriate_petition
    flag_petition_with_reason
    creator_should_see_the_flag_reason
  end
end

def create_inappropriate_petition
  register
  create_petition('Kill the Whales')
  click_link "launch-petition"
  log_out
end

def flag_petition_with_reason
  visit petition_path('kill-the-whales')
  click_link 'flag-petition'
  fill_in 'flag-reason', with: 'We should protect whales'
  click_link 'btn-flag'
  page.should have_content 'The petition has been flagged.'
end

def creator_should_see_the_flag_reason
  @org_admin = FactoryGirl.create(:org_admin, organisation: @current_organisation)
  log_in @org_admin.email
  visit moderation_queue_org_petitions_path('kill-the-whales')
  page.find(".flag-reason-link").click()
  page.should have_content 'We should protect whales'
  visit org_petitions_path('kill-the-whales')
  page.find(".flag-reason-link").click()
  page.should have_content 'We should protect whales'
end
