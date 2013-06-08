require 'spec_helper'

describe UsersController do
  include_context "setup_default_organisation"
  
  before :each do
    @user = Factory(:user, organisation: @organisation)
    sign_in @user
  end
  
  describe "#edit" do
    it "should render account edit page" do
      get :edit
      response.should render_template :edit
    end
  end
  
  describe "#update" do
    it "should update user and show notice" do
      params = { user: { "opt_out_site_email" => "1" } }
      users_service = users_service_mock
      users_service.should_receive(:update_attributes).with(@user, params[:user]) { true }
      
      put :update, params
      
      response.should redirect_to account_url
      flash[:notice].should match "have been updated"
    end
    
    it "should update user and show notice" do
      params = { user: { "opt_out_site_email" => "1" } }
      users_service = users_service_mock
      users_service.should_receive(:update_attributes).with(@user, params[:user]) { false }
      
      put :update, params
      
      response.should render_template :edit
    end

    it "should redirect to crop when image is present" do
      params = { user: {"image" => "image.gif"}}
      users_service = users_service_mock
      users_service.should_receive(:update_attributes).with(@user, params[:user]) {true}

      put :update, params

      response.should render_template :crop
    end
  end
  
  describe "#update_password" do
    it "should update user password and show notice" do
      subject.stub(:current_user) { @user }
      params = { user_password: { "current_password" => @user.password, "password" => "a", "password_confirmation" => "a" } }
      @user.should_receive(:update_with_password).with(params[:user_password]) { true }
      subject.should_receive(:sign_in).with(@user, bypass: true)
      
      put :update_password, params
      
      response.should redirect_to account_url
      flash[:notice].should match "has been updated"
    end
    
    it "should update user and show notice" do
      subject.stub(:current_user) { @user }
      params = { user_password: { "current_password" => @user.password, "password" => "a", "password_confirmation" => "a" } }
      @user.should_receive(:update_with_password).with(params[:user_password]) { false }
      @user.errors[:password] = "Failed to update"
      
      put :update_password, params
      
      response.should render_template :edit
    end
  end
  
  private
  
  def users_service_mock
    users_service = mock
    UsersService.stub(:new) { users_service }
    users_service
  end
end