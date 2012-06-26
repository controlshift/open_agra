require File.dirname(__FILE__) + '/scenario_helper.rb'

include LoginHelper

describe "Org admin administers efforts", :type => :request, :nip=> true do
  before(:each) do
    @org_admin = Factory(:org_admin, organisation: @current_organisation)
    log_in(@org_admin.email, "onlyusknowit")
  end

  it 'create a new effort & edit it' do
    click_on "#{@current_organisation.name} Admin"
    click_on "all-efforts"
    click_on "New Effort"
    fill_in "effort_title", with: "Effort Name"
    fill_in "Description", with: "Effort Description"
    fill_in "Title label", with: "Title Label"
    fill_in "Title help", with: "Title Help"
    fill_in "Title default", with: "Title default"

    click_on "Save"
    page.should have_content("Effort Name")
    page.should have_content("/efforts/effort-name")

    click_on "edit-effort"

    fill_in "effort_title", with: "Another Name"
    click_on "Save"

    page.should_not have_content("Effort Name")
    page.should have_content("Another Name")
    page.should have_content("/efforts/effort-name")
  end

  context "with an effort" do
    before(:each) do
      @effort = Factory(:effort, organisation: @current_organisation)
    end

    it "should list efforts" do
      click_on "#{@current_organisation.name} Admin"
      click_on "all-efforts"

      page.should have_content(@effort.title)
      click_on @effort.title

      page.should have_content("/efforts/#{@effort.slug}")

      click_on effort_url(@effort)

      page.should have_content(@effort.title)
      page.should have_content('Start A Campaign')
    end
  end
end
