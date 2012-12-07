require File.dirname(__FILE__) + '/scenario_helper.rb'

include LoginHelper
include PetitionHelper

describe "Campaigner", type: :request do
  before :each do
    register
    create_petition("Save the Whales")
    click_on "launch-petition"
    # requires a second petition to make the list page appaear
    create_petition("Save the River Cooks")
    click_on "launch-petition"
    visit petition_manage_path("save-the-whales")
  end

  it 'cancels petition and still able to manage it' do
    cancels
    views_and_manages
  end

  def cancels
    find_link("manage-hide")["data-confirm"].should include("hide this petition")
    click_on "manage-hide"
    page.should have_content "has been hidden"
    page.should have_link "Reactivate it?"
  end

  def views_and_manages
    click_on "View"
    page.should have_content "been hidden"
    page.should have_link "Reactivate it?"
  end

end
