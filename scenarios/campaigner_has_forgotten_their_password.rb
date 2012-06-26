require File.dirname(__FILE__) + '/scenario_helper.rb'

# nip tag means do not run this there.

describe "Campaigner forgets their password", type: :request, nip: true do

  include LoginHelper
  include EmailHelper

  before(:each) do
    case ActionMailer::Base.delivery_method
      when :test then
        ActionMailer::Base.deliveries.clear
      when :cache then
        ActionMailer::Base.clear_cache
    end
  end

  it "should send an email to allow campaigner to change password" do
    register 'First', 'Last', 'email@test.com', '123456'
    log_out

    click_link 'Log in'
    click_link 'Forgot password?'

    fill_in 'user_email', with: 'email@test.com'
    click_button 'send-password-reset'

    open_last_email_for('email@test.com')
    click_first_link_in_email

    page.should have_content('Change your password')

    fill_in 'user_password', with: '123abc'
    fill_in 'user_password_confirmation', with: '123abc'
    click_button 'change-my-password'

    page.should have_content('Your password was changed successfully')

    log_out

    log_in "email@test.com", "123456"
    page.should have_content('Invalid email or password.')
    log_in "email@test.com", "123abc"
    page.should have_content('Signed in successfully.')
  end

end
