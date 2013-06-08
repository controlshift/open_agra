require 'spec_helper'

describe PetitionsController do
  include_context "setup_default_organisation"
  include Shoulda::Matchers::ActionMailer
  include PetitionAttributesHelper

  describe "need to log in", "as guest" do
    before(:each) do
      @petition = FactoryGirl.create(:petition, organisation: @organisation)
    end

    [:edit].each do |action|
      it "GET #{action} should not allow non-logged user" do
        get action, id: @petition.slug
        response.should redirect_to new_user_session_path
      end
    end

    [:update].each do |action|
      it "PUT #{action} should not allow non-logged user" do
        put action, id: @petition.slug
        response.should redirect_to new_user_session_path
      end
    end
  end

  describe "#load_and_authorize_petition", "as a signed in user" do
    before :each do
      user = FactoryGirl.create(:user, organisation: @organisation)
      @petition = FactoryGirl.create(:petition, user: user, organisation: @organisation)
      unauthorised_user = FactoryGirl.create(:user)
      sign_in unauthorised_user
    end

    [:update].each do |action|
      it "PUT #{action} should not allow petition management for unauthorised user" do
        put action, id: @petition
        response.should redirect_to(root_path)
        flash[:alert].should == "You are not authorized to view that page."
      end
    end

    [:edit].each do |action|
      it "GET #{action} should not allow petition management for unauthorised user" do
        get action, id: @petition
        response.should redirect_to(root_path)
        flash[:alert].should == "You are not authorized to view that page."
      end
    end
  end

  describe "#new" do
    it "should prepare the petition model and render the new form" do
      get :new
      petition = assigns(:petition)
      petition.should be_kind_of(Petition)
      petition.campaigner_contactable.should be_true
      response.should render_template :new
    end
  end

  describe "#create" do
    context "valid petition" do
      context "user is logged in" do
        before(:each) do
          @user = FactoryGirl.create(:user, organisation: @organisation)
          sign_in @user
        end

        it "should send a proper object off to the petition service" do
          petition_attributes = Factory.attributes_for(:petition, user: nil, organisation: nil)
          petition_accessible_attributes = attributes_for_petition(petition_attributes)
          petition_accessible_attributes[:categorized_petitions_attributes] = attributes_for_categorized_petitions(@petition, petition_accessible_attributes[:category_ids])

          petition = mock()
          petition.should_receive(:user=).with(@user)
          petition.should_receive(:organisation=).with(@organisation)
          petition.should_receive(:effort).and_return(nil)
          Petition.should_receive(:new).with(petition_accessible_attributes).and_return(petition)

          petition_service = mock()
          petition_service.should_receive(:save).with(petition).and_return(true)
          PetitionsService.should_receive(:new).and_return(petition_service)

          post :create, petition: petition_attributes
          response.should redirect_to(launch_petition_path(assigns(:petition)))
        end
      end

      context "user is not logged in" do
        it "should redirect to sign up page" do
          post :create, petition: Factory.attributes_for(:petition)

          assigns(:petition).errors.count.should == 0
          Petition.count.should == 1
          assigns(:petition).token.should_not be_empty
          response.should redirect_to(new_user_registration_path(token: assigns(:petition).token))
        end
      end
    end

    describe "invalid petition" do
      it "should reject an invalid petition" do
        post :create, petition: Factory.attributes_for(:invalid_petition)
        response.should render_template :new
        assigns(:petition).errors.count.should > 0
        Petition.count.should == 0
      end
    end

    describe "with an effort that has categories" do
      before :each do
        @user = FactoryGirl.create(:user, organisation: @organisation)
        sign_in @user
        @category = FactoryGirl.create(:category, organisation: @organisation)
      end

      let(:effort) { FactoryGirl.create(:effort, categories: [@category], organisation: @organisation)  }

      context "when the effort category is chosen" do
        before :each do
          post :create, petition: Factory.attributes_for(:petition).merge(effort_id: effort.id, category_ids: [@category.id])
        end
        it "should exist" do
          assigns[:petition].reload.persisted?.should == true
        end
        it "should have the effort category" do
          assigns[:petition].reload.categories.should == [@category]
        end
      end
      context "when the effort category is not chosen" do
        before :each do
          post :create, petition: Factory.attributes_for(:petition).merge(effort_id: effort.id)
        end
        it "should exist" do
          assigns[:petition].reload.persisted?.should == true
        end
        it "should have the effort categories anyway" do
          assigns[:petition].reload.categories.should == [@category]
        end
      end
      context "when effort has a default_image" do
        let(:effort) { FactoryGirl.create(:effort, categories: [@category], organisation: @organisation, image_default: fixture_file_upload(File.join(Rails.root, 'spec', 'fixtures', "tiny_image.jpg"), 'image/jpg'))  }

        it "should copy over the image from the effort if no petition image is specified" do
          post :create, petition: Factory.attributes_for(:petition).merge(effort_id: effort.id)
          assigns[:petition].reload.image_file_name.should == "tiny_image.jpg"
        end
      end
    end
  end

  context "signed in" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      @petition = FactoryGirl.create(:petition, user: @user, organisation: @organisation)
      sign_in @user
    end

    describe "#index" do
      it "should render the list of current user's petitions" do
        second_petition = FactoryGirl.create(:petition, user: @user, organisation: @organisation)

        get :index
        response.should render_template :index
        assigns(:petitions).to_a.should =~ [@petition, second_petition]
      end

      it "should redirect to manage petition page if there's only one petition" do
        get :index
        response.should redirect_to petition_manage_path(@petition)
      end
    end

    describe "#search" do
      let(:query) { mock }

      it "should show campaigns by terms" do
        query.should_receive(:petitions) { [mock] }
        Queries::Petitions::DetailQuery.stub(:new).with(page: nil, organisation: @organisation, search_term: "test") { query }
        query.should_receive(:execute!)
        get :search, q: "test"
        response.should render_template :search
      end

      context "orphan petition" do

        it "should render views successfully" do
          orphan_petition = FactoryGirl.create(:petition_without_leader, title: "orphan", organisation: @organisation)
          petitions = [orphan_petition]
          query.should_receive(:petitions).any_number_of_times.and_return(petitions)
          petitions.stub(:current_page).and_return(1)
          petitions.stub(:total_pages).and_return(1)
          Queries::Petitions::DetailQuery.stub(:new).with(page: nil, organisation: @organisation, search_term: "orphan") { query }
          query.should_receive(:execute!)

          get :search, q: "orphan"

          assigns(:query).petitions.should include(orphan_petition)
        end
      end

      it "should show featured campaigns if no search result" do
        query.should_receive(:petitions) { nil }
        Queries::Petitions::DetailQuery.stub(:new).with(page: nil, organisation: @organisation, search_term: "test") { query }
        query.should_receive(:execute!)

        petitions = [mock]
        featured_query = mock
        featured_query.should_receive(:petitions) { petitions }
        Queries::Petitions::CategoryQuery.stub(:new).with(page: nil, organisation: @organisation) { featured_query }
        featured_query.should_receive(:execute!)

        get :search, q: "test"
        response.should render_template :search
        assigns(:featured_petitions).should == petitions
      end

      it "should show alert message when there's an error" do
        Queries::Petitions::DetailQuery.stub(:new) { query }
        query.should_receive(:execute!).and_raise(Errno::ECONNREFUSED)
        post :search
        response.should render_template :search
        flash[:alert].should match "Failed to search"
      end
    end

    describe "edit" do
      before(:each) do
        get :edit, id: @petition.slug
      end
      specify { response.should render_template('new') }
      specify { assigns(:petition).should == @petition }
    end

    describe "#launch" do
      context "organisation requires user confirmation on sign up" do
        before :each do
          @organisation.requires_user_confirmation_on_sign_up = '1'
          @organisation.save
          controller.stub(:current_user) { @user }
        end

        it "should redirect to confirmation page if user hasn't confirm yet" do
          @user.confirmed_at = nil
          put :launch, id: @petition
          response.should redirect_to new_user_confirmation_path
        end

        it "should continue to manage page" do
          @user.confirmed_at = Time.now
          put :launch, id: @petition
          response.should redirect_to petition_manage_path(@petition)
        end
      end

      it "should auto sign petition and go to manage page" do
        should_schedule_reminder_emails

        put :launch, id: @petition

        assigns(:petition).signatures.count.should == 1
        assigns(:petition).signatures[0].first_name == @user.first_name
        assigns(:petition).signatures[0].last_name == @user.last_name
        assigns(:petition).signatures[0].email == @user.email
        assigns(:petition).signatures[0].phone_number == @user.phone_number
        assigns(:petition).signatures[0].postcode == @user.postcode
        response.should redirect_to petition_manage_path(@petition)
      end

      def should_schedule_reminder_emails
        promote_petition_job = mock
        Jobs::PromotePetitionJob.stub(:new) { promote_petition_job }
        promote_petition_job.should_receive(:promote).with(@petition, :reminder_when_dormant)
      end
    end

    describe "#update" do
      describe "valid petition" do
        it "should redirect to share page" do
          petition_attributes = {'id' => '2'}
          controller.should_receive(:update_petition).with(@petition, petition_attributes, nil).and_return(true)
          put :update, id: @petition, petition: petition_attributes
          response.should redirect_to launch_petition_path(@petition)
        end
      end

      describe "invalid petition" do
        it "should render edit wizard page" do
          petition_attributes = {'id' => '2'}
          controller.should_receive(:update_petition).with(@petition, petition_attributes, nil).and_return(false)
          put :update, id: @petition, petition: petition_attributes
          response.should render_template :new
        end
      end

      describe 'location provided' do
        it 'passes location' do
          petition_attributes = {'id' => '2'}
          location_attributes = {'query' => 'Australia'}
          controller.should_receive(:update_petition).with(@petition, petition_attributes, location_attributes).and_return(true)
          put :update, id: @petition, petition: petition_attributes, location: location_attributes
          response.should redirect_to launch_petition_path(@petition)
        end
      end
    end
  end
end
