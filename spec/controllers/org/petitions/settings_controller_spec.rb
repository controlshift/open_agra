require 'spec_helper'

describe Org::Petitions::SettingsController do
  include_context "setup_default_organisation"

  before(:each) do
    @user = FactoryGirl.create(:org_admin, organisation: @organisation)
    sign_in @user
  end

  describe "#update" do
    before(:each) do
      @petition = FactoryGirl.create(:petition, organisation: @organisation, user: @user)
    end
    context "with a url" do
      before do
        @url = 'http://www.example.com/'
        put :update, petition_id: @petition, petition: { redirect_to: @url }
      end
      it "should set the redirect URL" do
        @petition.reload.redirect_to.should == @url
      end
    end
    context "without a url" do
      before do
        @url = nil
        put :update, petition_id: @petition, petition: { redirect_to: @url }
      end
      it "should clear the redirect URL" do
        @petition.reload.redirect_to.should be_nil
      end
    end
  end
end