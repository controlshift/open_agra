require 'spec_helper'

describe Org::Petitions::FlagsController do
  context "a petition and signed in user" do
    before :each do
      @organisation = Factory(:organisation)
      controller.stub(:current_organisation).and_return(@organisation)
      user = Factory(:org_admin, organisation: @organisation)
      @petition = Factory(:petition, organisation: @organisation)
      sign_in user
    end

    describe "#index" do
      context "no flags" do
        before { get :index, petition_id: @petition  }
        specify { response.should be_success }
        specify { assigns(:flags).should be_empty }
      end

      context "with two flags" do
        before(:each) do
          @old = Factory(:petition_flag, petition: @petition, created_at: 1.week.ago)
          @new = Factory(:petition_flag, petition: @petition)
          get :index, petition_id: @petition
        end

        specify { response.should be_success }

        it "should show the newest petition first" do
          assigns(:flags).should == [@new, @old]
        end
      end
    end
  end
end
