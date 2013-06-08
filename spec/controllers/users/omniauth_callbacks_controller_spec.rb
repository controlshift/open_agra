require 'spec_helper'

describe Users::OmniauthCallbacksController do
  include_context "setup_default_organisation"
  
  describe "#facebook" do
    let(:user) { Factory.build(:user, organisation: @organisation) }
    let(:petition) { Factory(:petition, organisation: @organisation) }
    let(:launch_petition_path) { "" }

    before :each do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @access_token = FactoryGirl.generate(:facebook_access_token)
      @request.env["omniauth.auth"] = @access_token
      @request.env["omniauth.params"] = { "token" => petition.token }
    end

    context "no user is signed in" do
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
        before(:each) do
          service = mock()
          PetitionsService.should_receive(:new) {service }
          service.stub(:link_petition_with_user!)
          launch_petition_path = ""
          session[:user_return_to] = launch_petition_path
        end

        it "should return an existing user object and go to launch page if no fb account exists" do
          User.should_receive(:find_by_facebook_id_and_organisation_id).with(@access_token.uid, @organisation.id) { nil }
          User.should_receive(:find_by_email_and_organisation_id).with(@access_token.info.email, @organisation.id) { user }

          post :facebook
          
          flash[:notice].should_not be_nil
          assigns(:token).should == petition.token
          assigns(:user).facebook_id.should == '1234'
          response.should redirect_to launch_petition_path
        end

        it "should return an existing user object and go to launch page if fb account exists" do
          User.should_receive(:find_by_facebook_id_and_organisation_id).with(@access_token.uid, @organisation.id) { user }

          post :facebook
          
          flash[:notice].should_not be_nil
          assigns(:token).should == petition.token
          assigns(:user).facebook_id.should == '1234'
          response.should redirect_to launch_petition_path
        end
      end
    end

    context "when a user is already signed in" do
      before(:each) do
        controller.stub(:current_user).and_return(user)
        session[:user_return_to] = launch_petition_path
      end

      it "should update the user's facebook id" do
        post :facebook
        
        flash[:notice].should_not be_nil
        assigns(:token).should == petition.token
        assigns(:user).facebook_id.should == '1234'
        response.should redirect_to launch_petition_path
      end

      context "user with an existing fb id" do
        let(:user) { Factory.build(:user, organisation: @organisation, facebook_id: '321') }

        it "should update the user's facebook id" do
          post :facebook
          assigns(:user).facebook_id.should == '1234'
        end
      end
    end
  end
end

