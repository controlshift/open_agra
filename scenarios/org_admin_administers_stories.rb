require File.dirname(__FILE__) + '/scenario_helper.rb'

include LoginHelper

describe "Org admin administers stories", :type => :request, :nip=> true do
  before(:each) do
    @org_admin = Factory(:org_admin, organisation: @current_organisation)
    log_in(@org_admin.email, "onlyusknowit")
  end

  specify 'create a new story, edit and return to list' do
    click_on "#{@current_organisation.name} Admin"
    click_on "all-stories"
    click_on "New Story"
    fill_in "Title", with: "Story Name"
    fill_in "Content", with: "Story Content"
    attach_file :image, Rails.root.join("scenarios/fixtures/white.jpg")

    click_on "Save"
    
    page.should have_content "Story Name"
    page.should have_content "Story Content"
    page.find(".petition-image img")[:src].should match "white.jpg"

    click_on "Edit"

    check "Featured"
    fill_in "Title", with: "Another Name"
    fill_in "Link", with: "http://www.google.com"
    click_on "Save"

    page.should have_content "Featured"
    page.should_not have_content "Story Name"
    page.should have_content "Another Name"
    page.should have_content "http://www.google.com"
    page.should have_content "Story Content"
    
    click_on "all-stories"
    page.should have_content "Another Name"
    page.should have_content "Story Content"
    
    visit root_path
    page.should have_content "Another Name"
    page.should have_content "Story Content"
    page.should have_xpath "//a[@href='http://www.google.com']"
  end
end
