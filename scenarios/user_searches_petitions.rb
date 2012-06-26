require File.dirname(__FILE__) + '/scenario_helper.rb'

include LoginHelper
include PetitionHelper

describe "User search petition", type: :request, nip: true do
  before :each do
    @petition = Factory(:petition, organisation: @current_organisation)
    @petition.update_attribute(:admin_status, :awesome)
  end
  
  it "searches", js: true do
    visit root_path
    fill_in "q", with: @petition.title
    click_on "search-campaign"
    
    page.current_path.should == search_petitions_path
    page.should have_content @petition.title
  end
end
