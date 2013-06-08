require 'spec_helper'

describe Petitions::SignaturesController do
  include_context "setup_default_organisation"

  context "signed in" do
    before(:each) do
      @user = Factory(:user, organisation: @organisation)
      sign_in @user
    end

    describe "#save_manual_input" do
      it "should raise exception if petition not found" do
        lambda { post :create, petition_id: "unfound_petition_id" }.should raise_exception(ActiveRecord::RecordNotFound)
      end

      context "a petition" do
        before(:each) do
          @petition = Factory(:petition, user: @user, organisation: @organisation)
        end

        it "should pluralise or not the alert and notice messages" do
          signatures = []
          signatures << Factory.attributes_for(:signature)
          signatures << Factory.attributes_for(:signature, phone_number: "not digit")
          post :save_manual_input, signatures: signatures, petition_id: @petition
          flash.now[:notice].should == "1 signature saved."
          flash.now[:alert].should == "1 signature cannot be saved."

          signatures.clear
          signatures << Factory.attributes_for(:signature)
          signatures << Factory.attributes_for(:signature)
          signatures << Factory.attributes_for(:signature, phone_number: "not digit")
          signatures << Factory.attributes_for(:signature, phone_number: "not digit")
          post :save_manual_input, signatures: signatures, petition_id: @petition
          flash.now[:notice].should == "2 signatures saved."
          flash.now[:alert].should == "2 signatures cannot be saved."

        end

        it "should save valid signatures" do
          signatures = []
          4.times { signatures << Factory.attributes_for(:signature) }

          post :save_manual_input, signatures: signatures, petition_id: @petition

          @petition.signatures.count.should == 4
          assigns(:error_rows).count.should == 0
          response.should redirect_to petition_manage_path(@petition)
        end

        it "should save valid signatures and discard blank ones" do
          signatures = []
          2.times { signatures << Factory.attributes_for(:blank_signature) }
          2.times { signatures << Factory.attributes_for(:signature) }
          2.times { signatures << Factory.attributes_for(:blank_signature) }

          post :save_manual_input, signatures: signatures, petition_id: @petition

          @petition.signatures.count.should == 2
          assigns(:error_rows).count.should == 0
          flash.now[:notice].should == "2 signatures saved."
          response.should redirect_to petition_manage_path(@petition)
        end

        it "should reject duplicates signatures with different cases" do
          signatures = []
          signatures << Factory.attributes_for(:signature, email: "anemail@email.com")
          signatures << Factory.attributes_for(:signature, email: "aNEMAil@email.com")
          signatures << Factory.attributes_for(:signature, email: "anemail@EMAIl.com")

          post :save_manual_input, signatures: signatures, petition_id: @petition

          @petition.signatures.count.should == 1
          assigns(:error_rows).count.should == 2
          flash.now[:notice].should == "1 signature saved."
          response.should be_success
        end

        it "should save valid signatures and return invalid ones" do
          signatures = []
          signatures << Factory.attributes_for(:signature, email: "bad format")
          2.times { signatures << Factory.attributes_for(:signature) }
          signatures << Factory.attributes_for(:signature, phone_number: "not digit")

          post :save_manual_input, signatures: signatures, petition_id: @petition

          @petition.signatures.count.should == 2
          assigns(:error_rows).count.should == 2
          assigns(:error_rows)[0][:errors].should_not be_empty
          assigns(:error_rows)[0][:errors][:email].should_not be_nil
          assigns(:error_rows)[1][:errors].should_not be_empty
          assigns(:error_rows)[1][:errors][:phone_number].should_not be_nil
          flash.now[:alert].should == "2 signatures cannot be saved."
          response.should render_template(:manual_input)
        end

        it "should not allow other user to submit signatures to my petition" do
          other_user = Factory(:user, organisation: @organisation)
          sign_in other_user

          signatures = []
          2.times { signatures << Factory.attributes_for(:signature) }

          post :save_manual_input, signatures: signatures, petition_id: @petition

          response.should redirect_to(root_path)
        end
      end
    end

    describe "#index" do
      it "should raise exception if petition not found" do
        lambda { get :index, petition_id: "unfound_petition_id" }.should raise_exception(ActiveRecord::RecordNotFound)
      end

      context "a petition and signature" do
        before(:each) do
          @petition = Factory.create(:petition, user: @user, organisation: @organisation)
          @signature = Factory.create(:signature, petition: @petition)
        end

        it "should export signatures for petition" do
          get :index, petition_id: @petition, format: :csv
          response.body.should start_with("id,first_name,last_name,phone_number,postcode")
        end

        it "should not export signatures for petition if user is not owner" do
          other_user = Factory.create(:user, organisation: @organisation)
          sign_in other_user
          get :index, petition_id: @petition, format: :csv
          response.body.should redirect_to(root_path)
        end
      end
    end
  end


  describe "#destroy" do
    before(:each) do
      @petition = Factory.create(:petition, user: @user, organisation: @organisation)
      @signature = Factory.create(:signature, petition: @petition)
    end

    context "a petition and signature exists" do
      before(:each) do
        delete :destroy, petition_id: @petition.slug, id: @signature
      end

      it "should destroy signature" do
        assigns[:signature].deleted_at.should_not be_nil
      end

      it "should redirect to the petition" do
        response.should redirect_to(@petition)
      end

    end

    context "wrong petition" do
      it "should throw exception if signature not found" do
        @other_petition = Factory.create(:petition, user: @user, organisation: @organisation)
        lambda { delete :destroy, petition_id: @other_petition.slug, id: @signature }.
            should raise_exception(ActiveRecord::RecordNotFound)
      end
    end

    context "wrong token" do
      it "should throw exception if signature not found" do
        lambda { delete :destroy, petition_id: @petition, id: "invalid_signature" }.
            should raise_exception(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "#create" do

    it "should raise exception if petition not found" do
      lambda { post :create, petition_id: "unfound_petition_id" }.should raise_exception(ActiveRecord::RecordNotFound)
    end

    context "a petition" do
      before(:each) do
        @user = Factory(:user, organisation: @organisation)
      end

      let(:petition) {  @petition = Factory(:petition, user: @user, organisation: @organisation) }

      it "should sign the petition" do
        petition.signatures.should be_empty
        @signature = Factory.attributes_for(:signature)
        post :create, {signature: @signature, petition_id: petition}
        petition.signatures.count.should == 1
        response.should redirect_to thanks_petition_path(petition)
      end

      context "petition with after_signature_redirect" do
        let(:petition) {  @petition = Factory(:petition, user: @user, organisation: @organisation, after_signature_redirect_url: 'http://www.google.com/') }

        it "should redirect to an alternate url" do
          post :create, {signature: Factory.attributes_for(:signature), petition_id: petition}
          response.should redirect_to 'http://www.google.com/'
        end
      end

      it "should sign the petition with mobile" do
        petition.signatures.should be_empty
        @signature = Factory.attributes_for(:signature)
        post :create, {signature: @signature, petition_id: petition, format: "mobile"}
        petition.signatures.count.should == 1
        response.should redirect_to thanks_petition_path(petition)
      end

      it "should not sign with insufficient info" do
        attributes = Factory.attributes_for(:signature)
        attributes.delete(:postcode)
        post :create, {signature: attributes, petition_id: petition}
        petition.signatures.count.should == 0
        response.should render_template('petitions/view/show')
      end

      it "should ignore signature whose email already exists" do
        signature = Factory.create(:signature, petition: petition)
        post :create, {signature: Factory.attributes_for(:signature, email: signature.email), petition_id: petition}
        petition.signatures.count.should == 1
        response.should redirect_to thanks_petition_path(petition)
      end

      it "should ignore signature whose email already exists with mobile" do
        signature = Factory.create(:signature, petition: petition)
        post :create, {signature: Factory.attributes_for(:signature, email: signature.email), petition_id: petition, format: "mobile"}
        petition.signatures.count.should == 1
        response.should redirect_to thanks_petition_path(petition)
      end
    end
  end

  describe "#unsubscribing" do
    before :each do
      @petition = Factory(:petition, organisation: @organisation)
      @signature = Factory(:signature, petition: @petition)
    end

    it "should response to unsubscribing" do
      get :unsubscribing, petition_id: @petition, id: @signature
      response.should be_success
    end

    it "should throw exception if signature not found" do
      lambda { get :unsubscribing, petition_id: @petition, id: "invalid_signature" }.
          should raise_exception(ActiveRecord::RecordNotFound)
    end
  end

  describe "#unsubscribe" do
    before :each do
      @campaigner = Factory(:user, organisation: @organisation)
      @petition = Factory(:petition, user: @campaigner, organisation: @organisation)
      @signature = Factory(:signature, petition: @petition)
    end

    it "should unsubcribe if the email matches and petition matches" do
      put :unsubscribe, petition_id: @petition, id: @signature, unsubscribe: {email: @signature.email}
      assigns(:signature).unsubscribe_at.should_not be_nil
      flash[:notice].should == 'You have successfully unsubscribed from the petition.'
    end

    it "should not unsubscribe if the emails not match" do
      another_signature = Factory(:signature, petition: @petition)

      put :unsubscribe, petition_id: @petition, id: @signature, unsubscribe: {email: another_signature.email}
      assigns(:signature).unsubscribe_at.should be_nil
      response.should render_template(:unsubscribing)
    end

    it "should not unsubscribe own petition" do
      own_signature = Factory(:signature, petition: @petition, email: @campaigner.email)

      put :unsubscribe, petition_id: @petition, id: own_signature, unsubscribe: {email: own_signature.email}
      assigns(:signature).unsubscribe_at.should be_nil
      response.should render_template(:unsubscribing)
    end

    it "should not unsubscribe if the petitions not match" do
      another_petition = Factory(:petition, organisation: @organisation)

      put :unsubscribe, petition_id: another_petition, id: @signature, unsubscribe: {email: @signature.email}
      assigns(:signature).unsubscribe_at.should be_nil
      response.should render_template(:unsubscribing)
    end

    it "should throw exception if signature not found" do
      lambda { put :unsubscribe, petition_id: @petition, id: "invalid_signature", unsubscribe: {email: @signature.email} }.
          should raise_exception(ActiveRecord::RecordNotFound)
    end
  end
end
