require 'spec_helper'

describe Org::Petitions::SignaturesController do
  context "a petition and signed in user" do
    before :each do
      @organisation = Factory(:organisation)
      controller.stub(:current_organisation).and_return(@organisation)
      user = Factory(:org_admin, organisation: @organisation)
      @petition = Factory(:petition, organisation: @organisation)
      sign_in user
    end

    describe "#index" do
      context "no signatures" do
        before { get :index, petition_id: @petition  }
        specify { response.should be_success }
        specify { assigns(:signatures).should be_empty }
      end

      context "with a signature" do
        before(:each) do
          @sig = Factory(:signature, petition: @petition)
          get :index, petition_id: @petition
        end

        specify { response.should be_success }
        specify { assigns(:signatures).should == [@sig]}

      end

      describe "#email" do
        context "with a signature" do
          before(:each) do
            @sig = Factory(:signature, petition: @petition)
            get :email, petition_id: @petition, email: @sig.email
          end

          specify { response.should be_success }
        end

        context "no signature" do
          before(:each) do
            get :email, petition_id: @petition, email: 'george@washington.com'
          end

          specify { response.should be_redirect }
        end
      end

      describe "#unsubscribe" do
        context "with a signature" do
          before(:each) do
            @sig = Factory(:signature, petition: @petition)
          end

          it "should allow unsubscribes" do
            put :unsubscribe, petition_id: @petition, id: @sig.id
            response.should be_redirect
            flash[:notice].should == "You have successfully unsubscribed #{@sig.email} from #{@petition.title}."
          end
        end
      end
    end
  end
end
