require File.dirname(__FILE__) + '/scenario_helper.rb'

include LoginHelper
include PetitionHelper

describe "Campaigner changes account details", type: :request do
  before :each do
    register
  end
  
  it "should change existing password with new one" do
    click_on "First Last"
    click_on "My Account"
    
    fill_in "First name", with: "Justin"
    fill_in "Last name", with: "Bieber"
    fill_in "Phone Number", with: "654321"
    fill_in "user_postcode", with: "2064"
    click_on "Save"
    
    page.should have_content "Your account details have been updated!"
    page.should have_content "Justin Bieber"
    find_field('Phone Number').value.should have_content "654321"
    find_field("user_postcode").value.should have_content "2064"
  end
end