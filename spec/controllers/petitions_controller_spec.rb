require 'spec_helper'

describe PetitionsController do
  include_context "setup_default_organisation"
  include Shoulda::Matchers::ActionMailer
  include PetitionAttributesHelpers

  describe "need to log in", "as guest" do
    before(:each) do
      @petition = Factory(:petition)
    end

    [:share, :edit].each do |action|
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
      user = Factory(:user)
      @petition = Factory(:petition, user: user)
      unauthorised_user = Factory(:user)
      sign_in unauthorised_user
    end

    [:update].each do |action|
      it "PUT #{action} should not allow petition management for unauthorised user" do
        put action, id: @petition
        response.should redirect_to(root_path)
        flash[:alert].should == "You are not authorized to view that page."
      end
    end

    [:share, :edit].each do |action|
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
          @user = Factory(:user, organisation: @organisation)
          sign_in @user
        end

        it "should send a proper object off to the petition service" do
          petition_attributes = Factory.attributes_for(:petition, user: nil, organisation: nil)
          petition_accessible_attributes = attributes_for_petition(petition_attributes)
          petition_accessible_attributes[:categorized_petitions_attributes] = attributes_for_categorized_petitions(@petition, petition_accessible_attributes[:category_ids])

          petition = mock()
          petition.should_receive(:user=).with(@user)
          petition.should_receive(:organisation=).with(@organisation)
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
  end

  context "signed in" do
    before(:each) do
      @user = Factory(:user)
      @petition = Factory(:petition, user: @user, organisation: @organisation)
      sign_in @user
    end

    describe "#index" do
      it "should render the list of current user's petitions" do
        second_petition = Factory(:petition, user: @user, organisation: @organisation)

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

    describe "share" do
      before(:each) do
        get :share, id: @petition.slug
      end
      specify { response.should render_template('share') }
      specify { assigns(:petition).should == @petition }
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
        
        it "should continue to share page" do
          @user.confirmed_at = Time.now
          put :launch, id: @petition
          response.should redirect_to :share_petition
        end
      end
      
      it "should auto sign petition and go to win page" do
        should_schedule_reminder_emails

        put :launch, id: @petition

        assigns(:petition).reload
        assigns(:petition).signatures.count.should == 1
        assigns(:petition).signatures[0].first_name == @user.first_name
        assigns(:petition).signatures[0].last_name == @user.last_name
        assigns(:petition).signatures[0].email == @user.email
        assigns(:petition).signatures[0].phone_number == @user.phone_number
        assigns(:petition).signatures[0].postcode == @user.postcode
        response.should redirect_to(:share_petition)
      end

      def should_schedule_reminder_emails
        promote_petition_job = mock
        Jobs::PromotePetitionJob.stub(:new) { promote_petition_job }
        promote_petition_job.should_receive(:promote).with(@petition, :reminder_when_dormant)
      end
    end

    describe "#update" do
      it "should allow changing categorized_petitions" do
        petition_attributes = { category_ids: ["1"] }
        subject.should_receive(:attributes_for_categorized_petitions).with(@petition, ["1"]) { {} }
        put :update, id: @petition, petition: petition_attributes
      end
      
      describe "valid petition" do
        it "should redirect to share page" do
          put :update, id: @petition, petition: @petition.attributes
          response.should redirect_to launch_petition_path(@petition)
        end
      end

      describe "invalid petition" do
        it "should render edit wizard page" do
          @petition.title = nil

          put :update, id: @petition, petition: @petition.attributes
          response.should render_template :new
        end
      end

      describe "petition source" do
        it "should allow changing source if it is not set" do
          put :update, id: @petition, petition: @petition.attributes.merge(source: "soy source")

          @petition.reload
          @petition.source.should == "soy source"
        end

        it "should not allow changing source if it is already set" do
          @petition.update_attribute(:source, "soy source")

          put :update, id: @petition, petition: @petition.attributes

          @petition.reload
          @petition.source.should == "soy source"
        end
      end
    end
  end

  describe "#contact" do
    before(:each) do
      @petition_owner = Factory(:user, organisation: @organisation)
      @petition_admin = Factory(:user, organisation: @organisation)
      @petition = Factory(:petition, user: @petition_owner, organisation: @organisation)
      Factory(:campaign_admin, petition: @petition, user: @petition_admin, invitation_email: @petition_admin.email)
      @email = Factory.attributes_for(:email)
    end

    context "valid contact email" do
      it "should send email to the current petition's campaigner" do
        post :contact, id: @petition, email: @email

        should_have_sent_contact_email
        response.should redirect_to petition_path(@petition)
        flash[:notice].should have_content "has been sent"
      end

      it "should not send email from supporter if campaigner is not contactable" do
        @petition.update_attribute(:campaigner_contactable, false)

        post :contact, id: @petition, email: @email

        response.should redirect_to petition_path(@petition)
        flash[:alert].should have_content "This campaigner doesn't want to be contacted at the moment"
      end

      it "should send email from org admin even if campaigner is not contactable" do
        @petition.update_attribute(:campaigner_contactable, false)

        org_admin = Factory(:org_admin, organisation: @organisation)
        sign_in org_admin

        post :contact, id: @petition, email: @email

        should_have_sent_contact_email
        response.should redirect_to petition_path(@petition)
        flash[:notice].should have_content "has been sent"
      end
    end

    context "invalid contact email" do
      it "redirect to the petition page with an alert message" do
        @email[:from_address] = "asdlajkd"
        @mailer = mock
        @mailer.should_not_receive(:deliver)
        UserMailer.should_not_receive(:contact_campaigner).and_return(@mailer)
        post :contact, id: @petition, email: @email

        response.should redirect_to petition_path(@petition)
        flash[:alert].should have_content "Invalid input"
      end
    end
  end

  def should_have_sent_contact_email
    Delayed::Job.count.should == @petition.admins.length
    success, failure = Delayed::Worker.new.work_off
    success.should == @petition.admins.length
    failure.should == 0
    should have_sent_email.with_subject(/#{@email[:subject]}/i)
                          .from(@email[:from_address])
                          .with_body(/#{@email[:content]}/i)
                          .to(@petition_owner.email)

    should have_sent_email.with_subject(/#{@email[:subject]}/i)
                          .from(@email[:from_address])
                          .with_body(/#{@email[:content]}/i)
                          .to(@petition_admin.email)
  end
end
