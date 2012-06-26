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
    let(:resource) { mock }
    let(:petition) { Factory(:petition) }
    
    def should_link_petition_with_user
      service = mock
      PetitionsService.should_receive(:new) { service }
      service.should_receive(:link_petition_with_user!).with(petition, resource)
    end
    
    def should_return_launch_petition_path
      controller.after_sign_in_path_for(resource).should == launch_petition_path(petition)
    end

    it "should return launch path if token exists in params" do
      controller.params[:token] = petition.token
      should_link_petition_with_user
      should_return_launch_petition_path
    end
    
    it "should return launch path if token exists as instance variable" do
      controller.token = petition.token
      should_link_petition_with_user
      should_return_launch_petition_path
    end

    it 'should return specific path in session' do
      controller.session[:user_return_to] =  "http://testtest.com"
      controller.after_sign_in_path_for(resource).should == "http://testtest.com"
    end
    
    it 'should return petitions path' do
      controller.after_sign_in_path_for(resource).should == petitions_path
    end
  end
end
