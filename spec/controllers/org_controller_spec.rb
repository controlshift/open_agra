require 'spec_helper'

describe Org::OrganisationController do
  include_context "setup_default_organisation"
  
  describe "#index" do
    context "not logged in" do
      before(:each) { get :show }

      specify{ response.should redirect_to(new_user_session_path) }
      specify{ response.should_not render_template(:index) }
    end

    it "should require users to be admins" do
      @user = Factory(:user, admin: false)
      sign_in @user

      get :show
      response.should redirect_to(root_path)
      flash[:alert].should == 'You are not authorized to view that page.'
      response.should_not render_template(:index)
    end

    it "should show admins a list of actions to perform" do
      @user = Factory(:user, admin: true)
      sign_in @user
      get :show

      response.should_not redirect_to(root_path)
      response.should render_template(:show)
    end

    it "should show org admins a list of actions to perform" do
      @user = Factory(:user, org_admin: true, :organisation => @organisation)
      sign_in @user
      get :show
      
      response.should_not redirect_to(root_path)
      response.should render_template(:show)
    end
  end

  describe "#settings" do
    before(:each) do
      @user = Factory(:user, org_admin: true, :organisation => @organisation)
      sign_in @user
    end

    it "should show the settings page" do
      get :settings
      response.should render_template(:settings)
    end
  end
end
