require File.dirname(__FILE__) + '/scenario_helper.rb'

include LoginHelper
include PetitionHelper
include EmailHelper

describe "Campaigner creates petition within an effort", type: :request, nip: true do

  context 'when user is logged in' do

    before(:each) do
      @effort = Factory(:effort, organisation: @current_organisation)
      @campaigner = Factory(:user, organisation: @current_organisation)
      log_in(@campaigner.email, "onlyusknowit")
    end
    
    it "should create petition inside an effort" do
      visit effort_url(@effort)
      page.should have_content(@effort.title)
      page.should have_content(@effort.description)

      click_on "Start A Campaign"
      fill_in_petition
      click_on 'Save'
      click_on "launch-petition"
      @petition = Petition.last
      @petition.update_attribute(:admin_status, :good)
      @petition.effort.should == @effort

      visit effort_url(@effort)
      page.should have_content(@petition.title)
    end
  end
end
