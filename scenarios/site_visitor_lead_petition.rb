require File.dirname(__FILE__) + '/scenario_helper.rb'

include LoginHelper

describe "user lead a petition", type: :request, js:true do
  let(:leader_duty_content) {'leader duty'}
  let(:target_name) {'target name'}

  before :each do
    @effort = create(:specific_targets_effort, organisation: @current_organisation, leader_duties_text: leader_duty_content, distance_limit: nil)
    @petition = create(:petition_without_leader, effort: @effort,
                                   target: create(:target, name: target_name),
                                   organisation: @current_organisation, location: create(:museum))
    Petition.index
  end

  context "if has already logged in" do
    before(:each) do
      create(:user, organisation: @current_organisation, email: "email@test.com")
      log_in
    end

    it "should commit as a leader directly" do
      visit effort_near_index_path(@effort)
      page.find("#closest-petition .lead-petition-btn").click

      page.should have_css ".what-I-am-leading-for"
      page.should have_css ".local-campaign-detail .target-name:contains('#{target_name}')"

      click_on "Commit as a Leader"

      current_path.should == training_effort_petition_path(@effort, @petition)
      page.should have_css ".training-content"
      page.should have_css ".training-sidebar-content"

      visit petitions_path
      page.should have_content @petition.title
    end

    context "if petition already has a leader" do
      it "should show detail of the leader instead" do
        @nearby_petition_with_leader = create(:target_petition, effort: @effort, organisation: @current_organisation,
                                                          location: create(:manly))
        Petition.index

        visit new_effort_near_path(@effort)

        fill_in 'location-query-field', with: 'Sydney, Australia'
        page.find('.search-effort').click

        page.should have_css(".nearby .nearby-petitions :contains('#{@nearby_petition_with_leader.user.full_name}')")
      end

      context "current user is on leading page" do
        it "should redirect current user to petition sign page" do
          petition_with_leader = create(:target_petition, effort: @effort, organisation: @current_organisation,
                                        location: create(:manly))
          visit leading_effort_petition_path(@effort, petition_with_leader)

          click_on "Commit as a Leader"

          page.should have_css(".sign-the-petition")
        end
      end
    end
  end

  context "if has not logged in" do
    it "should be able to log in and commit as a leader" do
      create(:user, organisation: @current_organisation, email: "email@test.com")

      visit effort_near_index_path(@effort)
      page.find("#closest-petition .lead-petition-btn").click

      page.should have_css ".lead-petition"
      page.should have_css ".what-I-am-leading-for"
      page.should have_css ".local-campaign-detail .target-name:contains('#{target_name}')"

      page.find(".login").click
      fill_and_submit_login_form("email@test.com", "onlyusknowit")

      current_path.should == training_effort_petition_path(@effort, @petition)

      visit petitions_path
      page.should have_content @petition.title
    end

    it "should be able to register and commit as a leader" do
      visit effort_near_index_path(@effort)
      page.find("#closest-petition .lead-petition-btn").click

      page.should have_css ".lead-petition"
      fill_and_submit_registration_form('First', 'Last', 'email@test.com', 'onlyusknowit')

      current_path.should == training_effort_petition_path(@effort, @petition)

      visit petitions_path
      page.should have_content @petition.title
     end
  end

  context "leader duty" do
    it "should show leader duty" do
      visit effort_near_index_path(@effort)

      click_on "What will I need to do?"

      page.find(".leader-duty-modal").should be_visible
      page.should have_content(leader_duty_content)
    end
  end
end