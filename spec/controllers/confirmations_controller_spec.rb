require 'spec_helper'

describe ConfirmationsController do
  include_context "setup_default_organisation"
  
  context "logged in and confirmed user" do
    before :each do
      @user = Factory(:user, confirmed_at: Time.now)
      sign_in @user
      @request.env["devise.mapping"] = Devise.mappings[:user]
    end
    
    context "no redirect path is inside the session" do
      [:new, :show].each do |action|
        it "#{action} redirects to the petitions path" do
          get action
          response.should redirect_to petitions_path
          flash[:notice].should == "You have already confirmed your email"
        end
      end

      describe "#create" do
        it "redirects to the petitions path" do
          post :create
          response.should redirect_to petitions_path
          flash[:notice].should == "You have already confirmed your email"
        end
      end
    end

    context "there is a redirect path inside the session" do
      before :each do
        session["after_confirmation_path"] = root_path
      end
      [:new, :show].each do |action|
        it "#{action} redirects to the petitions path" do
          get :show
          response.should redirect_to session["after_confirmation_path"] 
          flash[:notice].should == "You have already confirmed your email"
        end
      end

      describe "#create" do
        it "redirects to the petitions path" do
          post :create
          response.should redirect_to session["after_confirmation_path"] 
          flash[:notice].should == "You have already confirmed your email"
        end
      end
    end
  end
  
  context "anonymous user" do
    before :each do
      @request.env["devise.mapping"] = Devise.mappings[:user]
    end
    
    [:new, :show, :create].each do |action|
      specify "#{action} redirects to user login path" do
        get action
        response.should redirect_to new_user_session_path
      end
    end
  end

  describe "#after_resending_confirmation_instructions_path_for" do
    it "should still return the new confirmation path" do
      controller.send(:after_resending_confirmation_instructions_path_for, :user).should == new_user_confirmation_path
    end
  end

  describe "#after_confirmation_path_for" do
    let(:user) { Factory(:user) }

    it "should return the right path" do
      controller.send(:after_confirmation_path_for, :user, user).should == petitions_path
      session["after_confirmation_path"] = root_path
      controller.send(:after_confirmation_path_for, :user, user).should == root_path
    end
  end
end
