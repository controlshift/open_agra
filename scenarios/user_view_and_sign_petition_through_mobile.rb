require File.dirname(__FILE__) + '/scenario_helper.rb'

include LoginHelper
include PetitionHelper

describe "User view petition through mobile", type: :request, js: true do

  it "should allow user sign petition "  do
    set_user_agent_to_iphone

    register
    create_petition('Save the Whales')
    click_link "launch-petition"

    login_user_should_be_able_to_sign()

    non_login_user_should_be_able_to_sign()
  end

  def login_user_should_be_able_to_sign
    visit petition_path('save-the-whales')
    page.should have_content 'Save the Whales'

    click_button 'Sign'
    click_button 'Sign'
    page.should have_link 'Share on Facebook'
    page.should have_link 'Share on Twitter'
  end

  def non_login_user_should_be_able_to_sign
    find('.btn-navbar').click if find('.btn-navbar').visible?
    click_link 'Log out'
    visit petition_path('save-the-whales')

    click_button 'Sign'

    fill_in 'signature_first_name',  with: 'Huanhuan'
    fill_in 'signature_last_name', with: 'Huang'
    fill_in 'signature_email', with: 'hhuang@email.com'
    fill_in 'signature_phone_number', with: '123456'
    fill_in 'signature_postcode', with: '123456'

    click_button 'Sign'
    page.should have_link 'Share on Facebook'
    page.should have_link 'Share on Twitter'
  end

  private

  def set_user_agent_to_iphone
    user_agent = 'Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A543a Safari/419.3'
    page.driver.header('user-agent', user_agent)
  end
end