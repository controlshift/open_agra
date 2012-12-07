require File.dirname(__FILE__) + '/scenario_helper.rb'

include LoginHelper
include PetitionHelper

describe "Campaigner visits training page", :type => :request do
  before(:each) do
    user = create(:user, organisation: @current_organisation)
    effort = create(:specific_targets_effort, organisation: @current_organisation, training_text: "training text", distance_limit: nil)
    @petition = create(:target_petition, user: user, organisation: @current_organisation, effort: effort)
    log_in(user.email)
  end

  context "from manage page" do
     it "should render training content" do
       visit petition_manage_path(@petition)

       click_on "manage-training"

       page.should have_css(".training-box:contains('training text')")
     end
  end
end
