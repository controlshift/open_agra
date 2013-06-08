require File.dirname(__FILE__) + '/scenario_helper.rb'

include LoginHelper
include PetitionHelper

describe "Campaigner makes achievements", :type => :request do
  before(:each) do
    register
    create_petition('Save the Whales')
    click_on "launch-petition"
  end
  
  specify "step through achievements", js: true do
    visit petition_manage_path("save-the-whales")
    
    # accordion should not show any tick icon, and facebook accordion should be expanded
    find("#group-share_on_facebook .accordion-toggle img")[:src].should include "bullet-round-pending.png"
    find("#group-share_on_twitter .accordion-toggle img")[:src].should include "bullet-round-pending.png"
    find("#group-share_via_email .accordion-toggle img")[:src].should include "bullet-round-pending.png"
    find("#group-share_with_friends_on_facebook .accordion-toggle img")[:src].should include "bullet-round-pending.png"
    find("#collapse-share_on_facebook")[:class].should include "in"
    
    # share on facebook
    click_on "share_on_facebook_button"
    wait_until { find("#group-share_on_facebook .accordion-toggle img")[:src].include?("bullet-round-done.png") }
    
    # share via email
    click_on "view_email_template"
    wait_until { find("#group-share_via_email .accordion-toggle img")[:src].include?("bullet-round-done.png") }
    
    # refresh the page
    visit petition_manage_path("save-the-whales")
    
    # accordion should show some tick icon, and twitter accordion should be expanded
    find("#group-share_on_facebook .accordion-toggle img")[:src].should include "bullet-round-done.png"
    find("#group-share_on_twitter .accordion-toggle img")[:src].should include "bullet-round-pending.png"
    find("#group-share_via_email .accordion-toggle img")[:src].should include "bullet-round-done.png"
    find("#group-share_with_friends_on_facebook .accordion-toggle img")[:src].should include "bullet-round-pending.png"
    find("#collapse-share_with_friends_on_facebook")[:class].should include "in"
  end
end