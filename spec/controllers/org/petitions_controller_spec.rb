require 'spec_helper'

describe Org::PetitionsController do
  include_context "setup_default_organisation"
  
  before(:each) do
    @user = FactoryGirl.create(:org_admin, organisation: @organisation)
    sign_in @user
  end

  describe "#index" do
    it "should assign petition and render index template" do
      get :index
      assigns(:list).petitions.should == []
      should render_template :index
    end
  end

  context "with a few petition objects" do
    before(:each) do
      @petition = FactoryGirl.create(:petition, organisation: @organisation)
      @other_petition = FactoryGirl.create(:petition, organisation: FactoryGirl.create(:organisation))
    end

    describe "#index" do
      before(:each) { get :index }

      it { should assign_to :list }
      it { should render_template :index }
      specify { assigns(:list).petitions.should include(@petition) }
      specify { assigns(:list).petitions.should_not include(@other_petition) }
    end
  end

  describe "#search" do
    describe "for something" do
      before(:each) do
        Queries::Petitions::AdminQuery.should_receive(:new).with(search_term: 'jabberwocky', organisation: @organisation, page: nil)
                                           .and_return(@admin_query = mock())
        @results = mock()
        @admin_query.should_receive(:valid?).and_return(true)
        @admin_query.should_receive(:execute!).and_return(@results)

        get :search, query: 'jabberwocky'
      end

      it { should assign_to :query }
      it { should render_template :search }
    end

    context "orphan petition" do

      it "should render views successfully" do
        orphan_petition = FactoryGirl.create(:petition_without_leader, title: "orphan", organisation: @organisation)
        petitions = [orphan_petition]
        petitions.stub(:total_pages).and_return(1)
        query = mock()
        query.should_receive(:valid?).and_return(true)
        query.should_receive(:petitions).any_number_of_times.and_return(petitions)
        query.should_receive(:execute!)
        Queries::Petitions::AdminQuery.stub(:new).with(page: nil, organisation: @organisation, search_term: "orphan") { query }

        get :search, query: "orphan"

        assigns(:query).petitions.should include(orphan_petition)
      end
    end

    it "should catch raise exception and show flash alert if connection fail on search server" do
      Queries::Petitions::AdminQuery.should_receive(:new).with(any_args()).and_raise(Errno::ECONNREFUSED)
      get :search
      response.should render_template :search
      flash.now[:alert].should == 'Failed to search. Please contact technical support.'
    end
  end

  describe "#hot" do
    it "should response to #hot" do
      get :hot
      response.should be_success
    end

    it "should render #hot" do
      get :hot

      assigns(:petitions).each { |p| p.organisation_id.should == @organisation.id }
      response.should render_template :hot
    end
  end

  describe "#moderation_queue" do
    before(:each) do
      create_num_of_petitions_with_admin_status(:edited, 1)
      create_num_of_petitions_with_admin_status(:edited_inappropriate, 1)
      create_num_of_petitions_with_admin_status(:approved, 1)
      create_num_of_petitions_with_admin_status(:unreviewed, 1)
      FactoryGirl.create(:petition_without_leader, organisation: @organisation, admin_status: :unreviewed)
      get :moderation_queue
    end

    it "should response to #moderation_queue" do
      response.should be_success
    end

    it "should list unreviewed petitions even without leader" do
      assigns(:petitions).each { |p| p.organisation_id.should == @organisation.id }
      assigns(:num_of_new_petitions).should == 2
      assigns(:num_of_edited_petitions).should == 2
      response.should render_template :moderation_queue
    end

    def create_num_of_petitions_with_admin_status(admin_status, num_of_times)
      num_of_times.times do
        petition = FactoryGirl.create(:petition, organisation: @organisation, user: @user)
        petition.update_attribute(:admin_status, admin_status)
      end
    end
  end

  describe "#update" do
    context "petitions with user" do
      before(:each) do
        @petition = FactoryGirl.create(:petition, organisation: @organisation, user: @user)
      end

      it "should update admin status" do
        put :update, id: @petition, petition: {admin_status: :approved}

        flash[:notice].should == 'Moderation status of previous petition is updated successfully.'
      end

      it "should not update admin status if validation failed" do
        put :update, id: @petition, petition: {admin_status: :inappropriate}

        response.should render_template('petitions/view/show')
      end

      it "should record the admin_reason when admin_status is set to inappropriate" do
        PetitionsService.should_receive(:new).and_return(petition_service = mock())
        petition_service.should_receive(:save).with(@petition).and_return(true)

        new_reason = 'this is the reason.'
        put :update, id: @petition, petition: {admin_status: :inappropriate, admin_reason: new_reason}

        assigns(:petition).admin_reason.should == new_reason
      end

      Petition::ADMINISTRATIVE_STATUSES.each do |status|
        if status != :inappropriate
          it "should clear admin_reason when status is #{status}" do
            reason = 'this is the reason.'
            put :update, id: @petition, petition: {admin_status: status, admin_reason: reason}

            assigns(:petition).admin_reason.should be_nil
          end
        end
      end

      it "should redirect to next waiting moderation petition after update if next available" do
        another_petition = FactoryGirl.create(:petition, organisation: @organisation, user: @user)
        put :update, id: @petition, petition: {admin_status: 'approved'}

        response.should redirect_to petition_path(another_petition)
      end

      it "should stay on current petition after update if next not available" do
        put :update, id: @petition, petition: {admin_status: 'approved'}
        response.should redirect_to petition_path(@petition)
      end

      it "should not update admin status" do
        put :update, id: @petition, petition: {admin_status: 'asdsaf'}

        response.should_not redirect_to petition_path(@petition)
      end
    end
  end
end
