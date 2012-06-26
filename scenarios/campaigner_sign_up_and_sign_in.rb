require File.dirname(__FILE__) + '/scenario_helper.rb'

include LoginHelper

describe "Campaigner", type: :request do

  it 'signs up, signs in and signs out' do
    visit root_path
    page.should have_link('Log in')
    signs_up
    signs_out
    signs_in
    signs_out
  end

  def signs_up
    register("Johnny", "Depp", 'johnny@depp.com', 'onlyusknowit')
    page.should have_content('Johnny Depp')
    page.should have_content('signed up')
  end

  def signs_in
    log_in('johnny@depp.com', 'onlyusknowit')
    page.should have_content("Johnny Depp")
    page.should have_content('Signed in')
  end

  def signs_out
    log_out
    page.should have_content('Signed out')
  end
end
