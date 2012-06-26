require 'spec_helper'

describe SessionsController do
  include_context "setup_default_organisation"

  describe "#show_login_link" do
    it "should return false on login pages" do
      controller.send(:show_login_link).should be_false
    end
  end

  context 'when creating petition' do
    include_context "setup_default_organisation"

    it "should login campaigner and go to share page" do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      petition = Factory(:petition)

      post :create, user: Factory.attributes_for(:user), token: petition.token
    end
  end

  context 'sign in' do
    before :each do
      @user = Factory(:user, email: 'email@net.com', password: '123456', organisation: @organisation)
      @user_hash = Factory.attributes_for(:user, email: 'email@net.com', password: '123456')
      @request.env["devise.mapping"] = Devise.mappings[:user]
    end

    it 'should sign in if correct credentials' do
      post :create, user: @user_hash
      flash[:notice].should include 'Signed in'
      response.should redirect_to petitions_path
    end

    it 'should alert if password is incorrect' do
      @user_hash[:password] = '654321'
      post :create, user: @user_hash
      flash.alert.should == 'Invalid email or password.'
      response.should redirect_to new_user_session_path
    end

    it 'should alert if email is incorrect' do
      @user_hash[:email] = 'another@emai.com'
      post :create, user: @user_hash
      flash.alert.should == 'Invalid email or password.'
      response.should redirect_to new_user_session_path
    end
  end

  context "making sure the devise helpers are working properly" do
    it "should allow you to sign in saved users" do
      @user = Factory(:user)
      sign_in @user

      session['warden.user.user.key'][0].should == 'User'
      session['warden.user.user.key'][1].should_not be_nil
      session['warden.user.user.key'][1][0].should == @user.id
    end

    it "should not allow you to sign in unsaved users" do
      @user = User.new(id: 123)
      sign_in @user

      session['warden.user.user.key'][0].should == 'User'
      session['warden.user.user.key'][1].should be_nil
    end
  end
end