require 'spec_helper'

describe Users::OmniauthCallbacksController do
  include_context "setup_default_organisation"
  
  describe "#facebook" do
    let(:user) { Factory.build(:user, organisation: @organisation) }
    let(:petition) { Factory(:petition, organisation: @organisation) }

    before :each do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @access_token = FactoryGirl.generate(:facebook_access_token)
      @request.env["omniauth.auth"] = @access_token
      @request.env["omniauth.params"] = { "token" => petition.token }
    end

    context "new user" do
      it "should create a new user object" do
        User.should_receive(:find_by_email_and_organisation_id).with(@access_token.info.email, @organisation.id) { nil }
        post :facebook
        session[:facebook_access_token].should == @access_token.credentials.token
        assigns(:token).should == petition.token
        response.should render_template('users/registrations/completing')
      end
    end

    context 'existing user' do
      it "should return an existing user object and go to launch page" do
        User.should_receive(:find_by_email_and_organisation_id).with(@access_token.info.email, @organisation.id) { user }
        service = mock
        PetitionsService.should_receive(:new) { service }
        service.stub(:link_petition_with_user!)
        launch_petition_path = ""
        session[:user_return_to] = launch_petition_path

        post :facebook
        
        flash[:notice].should_not be_nil
        assigns(:token).should == petition.token
        assigns(:user).facebook_id.should == '1234'
        response.should redirect_to launch_petition_path
      end
    end
  end
end

