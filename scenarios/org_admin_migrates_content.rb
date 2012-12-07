require File.dirname(__FILE__) + '/scenario_helper.rb'

include LoginHelper

describe "Org admin migrates content", type: :request, nip: true do
  before(:each) do
    @org_admin = Factory(:org_admin, organisation: @current_organisation)
    @user = Factory(:user, organisation: @org_admin.organisation)
    log_in(@org_admin.email, "onlyusknowit")
  end

  it "should be able to export and then import downloaded content file." do
    Factory(:content, organisation: @org_admin.organisation)
    visit org_path
    click_on "Migrate"
    check "All"
    click_on "export-button"
    page.response_headers['Content-Type'].should == "application/json"

    visit org_path
    click_on "Migrate"
    attach_file "upload", Rails.root.join("spec/fixtures/sample_content.json")
    click_on "Import"
    page.should have_content "Content is imported successfully."
  end
end