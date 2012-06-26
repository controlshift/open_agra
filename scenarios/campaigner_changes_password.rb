require File.dirname(__FILE__) + '/scenario_helper.rb'

include LoginHelper
include PetitionHelper

describe "Campaigner changes password", type: :request do
  before :each do
    register
  end
  
  it "should change existing password with new one" do
    click_on "First Last"
    click_on "My Account"
    
    fill_in "Current password", with: "onlyusknowit"
    fill_in "New password", with: "abcd1234"
    fill_in "Confirm your new password", with: "abcd1234"
    click_on "Change my password"
    
    page.should have_content "Your Password has been updated!"
    
    log_out
    
    log_in "email@test.com", "abcd1234"
    
    page.should have_content "First Last"
  end
end