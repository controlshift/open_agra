require File.dirname(__FILE__) + '/scenario_helper.rb'

include LoginHelper

describe "Campaigner sign up with facebook", type: :request do

  it "should allow new campaigner to register" do
    pending "Need to be completed"
    visit new_user_registration_path
    click_on "Sign in with Facebook"
    page.should have_content("Johnny Depp")
  end

end


describe "Campaigner sign in with facebook", type: :request do
  context "has already sign up with facebook" do

  end

  context "has an account but not with facebook" do

  end

  context "is already logged in" do

  end
end



