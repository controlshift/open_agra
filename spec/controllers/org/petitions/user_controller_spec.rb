require 'spec_helper'

describe Org::Petitions::UserController do
  context "signed in" do
    before :each do
      @organisation = Factory(:organisation)
      controller.stub(:current_organisation).and_return(@organisation)
      user = Factory(:org_admin, organisation: @organisation)
      @petition = Factory(:petition, organisation: @organisation)
      sign_in user
    end

    it "should let you view user" do
      get :edit, petition_id: @petition
      response.should be_success
      assigns(:petition).should == @petition
    end

    it "should update petition with a new user" do
      user = create(:user, organisation: @organisation)
      post :update, petition_id: @petition, :user => { :email => user.email}
      response.should be_redirect

      assigns(:petition).user.should == user
    end
  end
end
