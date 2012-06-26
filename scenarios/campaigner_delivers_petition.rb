require File.dirname(__FILE__) + '/scenario_helper.rb'

include LoginHelper
include PetitionHelper

describe "Deliver petition", :type => :request do
  it "should try delivering via PDF and CSV" do
    register
    create_petition('Save the Whales')
    click_on "launch-petition"
    visit deliver_petition_manage_path('save-the-whales')

    click_on "download-letter"
    page.should have_content "You will receive an email with download instructions shortly."

    visit deliver_petition_manage_path('save-the-whales')
    click_on "export-signatures"
    page.response_headers['Content-Type'].should == "text/csv"
  end
end