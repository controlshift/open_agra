require File.dirname(__FILE__) + '/scenario_helper.rb'

include LoginHelper
include PetitionHelper

describe "Collect signatures offline", type: :request do
  before(:each) do
    register
    create_petition('Save the Whales')
    click_on "launch-petition"
  end

  specify "print a form and then bulk enter signatures", js: true do
    visit offline_petition_manage_path('save-the-whales')
    click_on "Printable Blank Form"
    page.response_headers['Content-Type'].should == "application/pdf"
    
    visit offline_petition_manage_path('save-the-whales')
    
    click_on "Enter Petition Signatures"
    page.should have_content("Enter petition signatures")

    #should have 5 blank rows by default
    page.should have_button "Add Row"
    page.all("#table-input tbody tr").count.should == 5

    #should add new row automatically when focus is on any input on last row
    fill_in 'signatures_4_first_name',  with: "Sam"
    fill_in 'signatures_4_last_name',  with: "Mc"
    fill_in'signatures_4_email', with: "baba@gmail.com"
    fill_in 'signatures_4_postcode',  with: "2000"
    page.all("#table-input tbody tr").count.should == 6

    #should be able to add row manually
    click_on "Add Row"
    page.all("#table-input tbody tr").count.should == 7

    #should be able to save valid signatures and reject invalid ones
    fill_in 'signatures_0_first_name',  with: "James"
    fill_in 'signatures_0_last_name',  with: "Crisp"
    fill_in 'signatures_0_email',  with: "abc@gmail.com"
    fill_in 'signatures_0_postcode',  with: "2000"
    fill_in 'signatures_1_first_name',  with: "Nathan"
    fill_in 'signatures_1_last_name',  with: "Woodhull"
    fill_in 'signatures_1_email',  with: "def@gmail.com"
    fill_in 'signatures_1_postcode',  with: "2064"

    fill_in 'signatures_2_first_name',  with: "!@!@!@"
    fill_in 'signatures_2_last_name',  with: "Ho"
    fill_in 'signatures_2_email',  with: "abc@gmail.com"
    fill_in 'signatures_2_postcode',  with: "2000"
    fill_in 'signatures_3_first_name',  with: "Fred"
    fill_in 'signatures_3_last_name',  with: "?*&()"
    fill_in 'signatures_3_email',  with: "def@gmail.com"
    fill_in 'signatures_3_postcode',  with: "2064"

    click_on "Save Signatures"

    page.should have_content("3 signatures saved")
    page.should have_content("2 signatures cannot be saved")

    find_field("signatures_0_first_name").value.should == "!@!@!@"
    find_field("signatures_0_email").value.should == "abc@gmail.com"
    find_field("signatures_0_postcode").value.should == "2000"
    find_field("signatures_1_last_name").value.should == "?*&()"
    find_field("signatures_1_email").value.should == "def@gmail.com"
    find_field("signatures_1_postcode").value.should == "2064"
  end
end
