require 'spec_helper'

describe RegistrationsController do
  include_context "setup_default_organisation"
  include Shoulda::Matchers::ActionMailer

  before :each do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "#post" do
    context 'when user is not in the white list' do
      before :each do
        @organisation.stub(:use_white_list?).and_return(true)
      end

      it "should deny user to register" do
        petition = Factory(:petition, organisation: @organisation)
        post :create, user: Factory.attributes_for(:user), token: petition.token

        flash.alert.should == "Did you receive an email with an invitation to use this site? If so, you can only register using that email address. You may have tried to use a different address; please click the back button and try again."
        response.should redirect_to intro_path
      end

      it "should render the view if petition token is provided but user's email leave blank" do
        petition = Factory(:petition, organisation: @organisation)

        post :create, user: Factory.attributes_for(:user, email: ""), token: petition.token
        response.should render_template :new
      end

      it "should allow thoughtworkers and getup staff to register" do
        getup_email = EmailWhiteList.create!(email: "email@getup.org.au").email
        thoughtworks_email = EmailWhiteList.create!(email: "email@thoughtworks.com").email
        test_registration_with_email(getup_email, true)
        test_registration_with_email(thoughtworks_email, true)
      end

      it "should not allow any getup staff or thoughtworks staff to register" do
        test_registration_with_email('made_up_email@getup.org.au', false)
        test_registration_with_email('i-dont-exist@thoughtworks.com', false)
      end
    end

    context 'when user is in the white list' do
      before :each do
        @organisation.stub(:use_white_list?).and_return(true)
        @email = EmailWhiteList.create!(email: "email@email.com").email
        @user_attr = Factory.attributes_for(:user, email: @email)
      end

      it "should be able to register new campaigner and go to launch page" do
        petition = Factory(:petition, organisation: @organisation)
        
        post :create, user: @user_attr, token: petition.token
        
        Petition.find_by_token(petition.token).user_id.should_not be_nil
        response.should redirect_to launch_petition_path(petition)
      end

      it "should link user to petition and notify partner org" do
        petition = Factory(:petition, organisation: @organisation)
        
        service = mock
        PetitionsService.stub(:new) { service }
        service.should_receive(:link_petition_with_user!).with(petition, kind_of(User))
        
        post :create, user: @user_attr, token: petition.token
      end

      it "should allow email in the whitelist to register regardless case" do
        petition = Factory(:petition, organisation: @organisation)
        @user_attr[:email] = @email.capitalize
        
        post :create, user: @user_attr, token: petition.token
        
        response.should redirect_to(launch_petition_path(petition))
      end

      it "should render the view if petition token is provided but user not save successfully" do
        petition = Factory(:petition, organisation: @organisation)

        post :create, user: Factory.attributes_for(:user, first_name: "", email: @email), token: petition.token
        response.should render_template :new
      end

      it "should redirect to home page if petition token not provided" do
        post :create, user: Factory.attributes_for(:user, email: @email)
        response.should redirect_to root_path
      end

      it "should render the view if petition token not provided and user not save successfully " do
        post :create, user: Factory.attributes_for(:user, first_name: "", email: @email)
        response.should render_template :new
      end

      it "should throw record not found exception if petition token is invalid" do
        -> { post :create, user: Factory.attributes_for(:user, email: @email), token: "invalid_token" }.
            should raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when the organisation does not use the white list" do
      it "should allow anyone in" do
        test_registration_with_email('foo@bar.com', true)
      end
    end
  end

  describe "#new" do
    it "should allow no token provided" do
      get :new
      response.should render_template :new
    end

    it "should render user sign up page" do
      petition = Factory(:petition, organisation: @organisation)

      get :new, token: petition.token
      response.should render_template :new
    end
  end

  
  describe "#complete" do
    let(:user_attr) { Factory.attributes_for(:user) }
    
    it "should create user if valid" do
      subject.should_receive(:create)
      # expect to have missing template exception because the template is rendered in stub method
      -> { post :complete, user: user_attr }.should raise_error(ActionView::MissingTemplate)
    end
    
    it "should render completing if invalid" do
      user_attr['first_name'] = ''
      post :complete, user: user_attr
      flash[:alert].should match 'First name'
      response.should render_template :completing
    end
  end

  it "should not show login link" do
    controller.send(:show_login_link).should be_false
  end

  def test_registration_with_email(email, should_register)
    user = Factory.attributes_for(:user)
    user[:email] = email
    post :create, user: user
    should_register ? flash.notice.should == "Welcome! You have signed up successfully." : flash.alert.should == 'Did you receive an email with an invitation to use this site? If so, you can only register using that email address. You may have tried to use a different address; please click the back button and try again.'
  end
end
