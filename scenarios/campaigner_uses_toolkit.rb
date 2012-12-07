require File.dirname(__FILE__) + '/scenario_helper.rb'

include LoginHelper
include PetitionHelper

describe "Campaigner has more than one petition", :type => :request do
  before(:each) do
    register
    create_petition('Save the Whales')
    click_on "launch-petition"
    create_petition('Harvey No')
    click_on "launch-petition"
    log_out
  end

  it 'views list of petitions and decides to create a new one' do
    log_in

    page.should have_content("My Campaigns")
    page.should have_link("Start a campaign")
    page.should have_link("Save the Whales")
    page.should have_link("Harvey No")

    click_on("Start a campaign")
    current_url.should == new_petition_url(:source => 'header')
  end

  it 'should view number of signatures and goals for a petition', js: true do
    sign_petition('save-the-whales', 'Fred', 'Lemay', 'flemay@thoughtworks.com')
    sign_petition('save-the-whales', 'James', 'Crisp', 'jcrisp@thoughtworks.com')
    sign_petition('save-the-whales', 'Sean', 'Ho', 'seanho@thoughtworks.com')
    log_in

    page.should have_content('4 of 100 signatures')
    page.should have_xpath("//div[@class='progressbar done' and @style='width:4%']")
  end
end
 
describe "Campaigner visits manage petition page", :type => :request do
  before(:each) do
    @user = Factory(:user, organisation: @current_organisation)
    @petition = Factory(:petition, user: @user, organisation: @current_organisation)
    log_in(@user.email)
  end

  it 'should have petition tools' do
    visit petition_manage_path(@petition)

    page.should have_content(@petition.title)
    page.should have_link("manage-email")
    page.should have_link("manage-collect")
    page.should have_link("manage-deliver")
  end
  
  context "petition is marked as inappropriate" do
    before(:each) do
      @petition.update_attribute(:admin_status, :inappropriate)
      @petition.update_attribute(:admin_reason, "A specific reason")
      @petition.update_attribute(:administered_at, Time.now)
    end
    
    it "should not be able to manage petition" do
      visit petition_manage_path(@petition)
      
      page.should have_content "We Found A Problem With"
      page.should have_content @petition.admin_reason
      page.should have_link "Edit", href: edit_petition_manage_path(@petition)
    end
    
    it "should be able to contact site administrator" do
      visit petition_manage_path(@petition)
      
      fill_in "email[subject]", with: "Nonsense"
      fill_in "email[content]", with: "Why are you blocking my petition?"
      click_on "Send"
      
      page.should have_content "Thank you for contacting us, we will review your petition soon."
    end
  end
end
