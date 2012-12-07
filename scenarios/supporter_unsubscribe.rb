require File.dirname(__FILE__) + '/scenario_helper.rb'

describe "unsubscribe", type: :request, nip: true do
  before :each do
    @petition = Factory(:petition, organisation: @current_organisation)
    @signature = Factory(:signature, petition: @petition)
  end

  context "visit unsubscribe page" do
    before(:each) do
      visit unsubscribing_petition_signature_path(petition_id: @petition, id: @signature)
    end

    it "should not unsubscribe if emails not matches" do
      fill_in "Enter your email address", with: "ramdonBlah@blah.com"
      click_on "Confirm"
      page.should have_content("Email does not match.")
    end

    it "should unsubscribe if petitions matches and email matches" do
      find_field("Enter your email address").value.should be_empty
      fill_in "Enter your email address", with: @signature.email
      click_on "Confirm"
      page.should have_content("You have successfully unsubscribed from the petition.")
    end
  end

  it "should not unsubscribe if petitions not matches" do
    another_petition = Factory(:petition, organisation: @current_organisation)
    visit unsubscribing_petition_signature_path(petition_id: another_petition, id: @signature)
    fill_in "Enter your email address", with: @signature.email
    click_on "Confirm"
    page.should have_content("The signature and the petition must match")
  end


end