require 'spec_helper'

describe Admin::AdminController do
  include_context "setup_default_organisation"
  
  describe "#index" do
    context "not logged in" do
      before(:each) { get :index }

      it "should make the person log in" do
        response.should redirect_to(new_user_session_path)
        response.should_not render_template(:index)
      end
    end

    context "signed in as a non admin" do
      before(:each) do
        @user = Factory(:user, admin: false, organisation: @organisation)
        sign_in @user
      end

      it "should require users to be admins" do
        get :index
        response.should redirect_to(root_path)
        flash[:alert].should == 'You are not authorized to view that page.'
        response.should_not render_template(:index)
      end
    end

   context "signed in as an admin" do
     before(:each) do
       @user = Factory(:user, admin: true, organisation: @organisation)
       sign_in @user
     end

      it "should show admins a list of actions to perform" do
        get :index

        response.should_not redirect_to(root_path)
        response.should render_template(:index)
      end
    end
  end
end
