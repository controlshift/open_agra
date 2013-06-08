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
      it "should render success response" do
        get :signatures
        response.should be_success
      end

      it "should render being uploaded page when number of rows are more than 30k" do
        Sidekiq::Worker.clear_all
        Queries::Exports::SignaturesExport.any_instance.stub(:total_rows).and_return(30001)
        request.env["HTTP_REFERER"] = '/'
        get :signatures
        response.should be_redirect
        flash[:notice].should == 'Your CSV is being generated. Please check your email after some time to get the download link.'
        Sidekiq::Worker.jobs.count.should == 1
      end
    end

    describe "petitions" do
      before(:each) do
        get :petitions
      end

      specify  { response.should be_success }
    end
  end
end
