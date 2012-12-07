require 'spec_helper'

describe Efforts::PetitionsController do
  include_context "setup_default_organisation"

  before(:each) do
    @user = Factory(:user, organisation: @organisation)
    @effort = Factory(:effort, organisation: @organisation)
  end

  describe "#new" do
    before(:each) do
      get :new, effort_id: @effort.slug
    end

    it { should assign_to :effort }
    it { should assign_to :petition }
    it { should render_template :new }

    it "should make the petition have the right effort" do
      assigns(:petition).effort.should == @effort
    end
  end

  context "user has logged in, with a leaderless petition" do
    before(:each) do
      sign_in @user
      @petition = create(:petition_without_leader, organisation: @organisation, effort: @effort)
    end

    describe "#lead" do
      it "should auto sign the petition by the leader, change the progress to lead and then go to training page" do
        put :lead, id: @petition, effort_id: @effort

        assigns(:petition).signatures.count.should == 1
        assigns(:petition).signatures.first.first_name == @user.first_name
        assigns(:petition).effort.signatures_size.should == @petition.signatures.count

        assigns(:petition).progress.should == "lead"
        response.should redirect_to training_effort_petition_path(@effort, @petition)
      end

      it "should ignore signature whose email already exists" do
        create(:signature, email: @user.email, petition: @petition)

        put :lead, id: @petition, effort_id: @effort

        assigns(:petition).signatures.count.should == 1
        response.should redirect_to training_effort_petition_path(@effort, @petition)
      end
    end

    describe "#leading" do
      it "should GET the leading page" do
        get :leading, id: @petition, effort_id: @effort

        response.should render_template "leading"
        response.should be_success
      end
    end
  end

  describe "#train" do
    before(:each) do
      sign_in @user
      @effort = build(:specific_targets_effort, organisation: @organisation)
      @petition = create(:target_petition, user: @user, organisation: @organisation, effort: @effort)
    end

    it "should change the progress to training and then redirect to petition manage page if effort doesn't prompt edit petitions as default" do
      @effort.save

      put :train, id: @petition, effort_id: @effort

      assigns(:petition).progress.should == "training"
      response.should redirect_to petition_manage_path(@petition)
    end

    it "should change the progress to training and then redirect to effort petition edit page if effort prompt edit petitions" do
      @effort.prompt_edit_individual_petition = true
      @effort.save

      put :train, id: @petition, effort_id: @effort

      assigns(:petition).progress.should == "training"
      response.should redirect_to edit_effort_petition_path(@effort, @petition)
    end
  end
end