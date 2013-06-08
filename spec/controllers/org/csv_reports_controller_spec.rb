require 'spec_helper'

describe Org::CsvReportsController do
  include_context "setup_default_organisation"

  context "signed in user" do
    before :each do
      @user = Factory(:org_admin, organisation: @organisation)
      sign_in @user
    end

    context "a csv report" do
      before(:each) do
        @report = FactoryGirl.create(:csv_report, exported_by: @user)
      end

      describe "#show" do
        before(:each) do
          get :show, id: @report.id
        end

        specify  { response.should be_redirect }
      end
    end

  end
end