require File.dirname(__FILE__) + '/scenario_helper.rb'

include LoginHelper
include PetitionHelper

describe "Campaigner set petition short url", type: :request do
  before :each do
    register
    create_petition("Save the Whales")
    click_on "launch-petition"
    visit petition_manage_path("save-the-whales")
  end

  it 'set petition short url and visit', js: true do
    set_petition_short_url
    visit_petition_with_alias
  end

  def set_petition_short_url
    click_on "Set Short URL"
    wait_until { find('#petition-alias-modal').visible? }
    
    fill_in "petition-alias-textbox", with: "save-whales"
    wait_until { page.has_no_css?('#btn-confirm.disabled') }
    
    click_on "Confirm"
    wait_until { find('.double-confirm').visible? }
    
    click_on "Confirm"
    wait_until { !find('#petition-alias-modal').visible? }
    
    page.should_not have_selector("#set-short-url", visible: true)
  end

  def visit_petition_with_alias
    visit petition_alias_path("save-whales")
    current_path.should == petition_path("save-the-whales")
    page.should have_content "Save the Whales"
  end
end
