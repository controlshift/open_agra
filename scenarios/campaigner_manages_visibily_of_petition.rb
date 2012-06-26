require File.dirname(__FILE__) + '/scenario_helper.rb'

include LoginHelper
include PetitionHelper

describe "Campaigner activates a cancelled petition", type: :request do
  before(:each) do
    # create the first petition
    register
    create_petition('Save the Whales')
    click_on "launch-petition"
  end

  it "should support toggling the visibility back and forth" do
    # hide the petition
    visit petition_manage_path('save-the-whales')
    click_on "manage-hide"
    check_hidden

    # the show path should also be hidden
    visit petition_path('save-the-whales')
    check_hidden

    # reactivate the petition
    click_on "Reactivate it?"
    check_reactivated

    # should also be able to do this from the view page.
    visit petition_manage_path('save-the-whales')
    click_on "manage-hide"
    check_hidden

    visit petition_path('save-the-whales')
    click_on "Reactivate it?"
    check_reactivated
  end

  def check_hidden
    page.should have_content "been hidden"
  end

  def check_reactivated
    page.should have_content("has been reactivated")
    page.should_not have_content("[Cancelled] Save the Whales")
    page.should have_content("Save the Whales")
  end
end
