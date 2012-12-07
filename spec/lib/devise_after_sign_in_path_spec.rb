require 'spec_helper'

class DummyController
  include Rails.application.routes.url_helpers
  include DeviseAfterSignInPath
  attr_accessor :params, :session, :token
  def initialize
    @params = {}
    @session = {}
  end
end

describe DeviseAfterSignInPath do
  include Rails.application.routes.url_helpers
  
  describe '#after_sign_in_path_for' do
    let(:controller) { DummyController.new }
    let(:resource) { mock_model(User) }
    let(:petition) { mock_model(Petition) }
    let(:token) { '123abc' }

    before(:each) do
      Petition.stub(:find_by_token!).with(token).and_return(petition)
    end

    context "an expectant PetitionsService" do
      before(:each) do
        service = mock
        PetitionsService.should_receive(:new) { service }
        service.should_receive(:link_petition_with_user!).with(petition, resource)
      end

      it "should return launch path if from petition start page" do
        controller.params[:token] = token
        controller.session[:user_return_to] = launch_petition_path(petition)
        controller.after_sign_in_path_for(resource).should == launch_petition_path(petition)
      end

      it "should work when the token is pre-assigned" do
        controller.stub(:token).and_return(token)
        controller.session[:user_return_to] = launch_petition_path(petition)
        controller.after_sign_in_path_for(resource).should == launch_petition_path(petition)
      end

      it "should return petitions path if user_return_to does not exist in session accidentally" do
        controller.params[:token] = token
        controller.after_sign_in_path_for(resource).should == petitions_path
      end
    end

    it 'should return specific path in session' do
      controller.session[:user_return_to] =  "http://testtest.com"
      controller.after_sign_in_path_for(resource).should == "http://testtest.com"
    end

    context 'as a normal user' do
      before(:each) do
        resource.stub(:org_admin?).and_return(false)
      end

      it 'should return petitions path' do
        controller.after_sign_in_path_for(resource).should == petitions_path
      end
    end

    context 'as an org admin' do
      before(:each) do
        resource.stub(:org_admin?).and_return(true)
      end

      it 'should return petitions path' do
        controller.after_sign_in_path_for(resource).should == org_path
      end
    end
  end
end
