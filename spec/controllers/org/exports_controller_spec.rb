require 'spec_helper'

describe Org::ExportsController do
  context "logged in" do
    before :each do
      @organisation = Factory(:organisation)
      controller.stub(:current_organisation).and_return(@organisation)
      user = Factory(:org_admin, organisation: @organisation)
      sign_in user
    end

    describe "index" do
      before(:each) { get :index }

      specify { response.should be_success }
    end

    describe "signatures" do
      before(:each) do
        get :signatures
      end

      specify  { response.should be_success }
    end

    describe "petitions" do
      before(:each) do
        get :petitions
      end

      specify  { response.should be_success }
    end
  end
end
