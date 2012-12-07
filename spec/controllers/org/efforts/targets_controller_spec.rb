require 'spec_helper'

describe Org::Efforts::TargetsController do
  include_context "setup_default_organisation"

  before :each do
    org_admin = Factory(:org_admin, organisation: @organisation)
    @effort = Factory(:specific_targets_effort, organisation: @organisation)
    sign_in(org_admin)
  end

  describe "#new" do
    it "should get create target form when directly visit new target page" do
      get :new, effort_id: @effort.slug
      response.should render_template :new
    end
  end

  describe "#create" do
    context "create target with valid info" do
      it "should redirect to org effort page" do
        post :create, target: {name: 'target name', phone_number: '123456789', email: '123@abc.com'}, effort_id: @effort.slug, location: Factory.attributes_for(:location)
        response.should redirect_to org_effort_path(@effort.slug)
      end

      it "should create a petition with current effort and target info" do
        post :create, target: {name: 'target name', phone_number: '123456789', email: '123@abc.com'}, effort_id: @effort.slug, location: Factory.attributes_for(:location)
        target = Target.find_by_name('target name')
        petition = Petition.find_by_title("#{@effort.title_default}: #{target.name}")
        petition.what.should == @effort.what_default
        petition.why.should == @effort.why_default
        petition.who.should == target.name
        petition.location.should == target.location
        petition.effort.should == @effort
        petition.target.should == target
        petition.launched.should == true
        petition.admin_status.should == :good
      end
    end

    context "create target with invalid info" do
      it "should alert error message when either name or location is missing" do
        post :create, target: {name: ''}, effort_id: @effort.slug
        response.should render_template :new
        assigns(:target).errors.count.should == 2
        Target.count.should == 0
      end

      it "should alert error message when phone number is invalid" do
        post :create, target: {name: 'target name', phone_number: 'abc1234'}, effort_id: @effort.slug, location: Factory.attributes_for(:location)
        response.should render_template :new
        assigns(:target).errors.count.should == 1
        Target.count.should == 0
      end
    end
  end

  describe "#update" do
    before :each do
      location = Factory(:location)
      @target = Factory.create(:target, name: "target name", phone_number: "12345678", email: "test@abc.com", location: location, organisation: @organisation)
      @petition = Factory(:target_petition, target: @target, effort: @effort, title: "#{@effort.title_default}: #{@target.name}", location: location, organisation: @organisation)

      @updated_location = Factory.attributes_for(:location)
      @updated_number = "8765432"
      @updated_email = "update@abc.com"
    end

    context "update target with valid information" do
      before :each do
        put :update, target: {phone_number: @updated_number, email: @updated_email}, location: @updated_location, effort_id: @effort.slug, id: @target.slug
      end

      it "should update target information" do
        @target.reload
        @target.phone_number.should == @updated_number
        @target.email.should == @updated_email
        @target.location.query.should == @updated_location[:query]
      end

      it "should update petition information when update target" do
        @petition.reload
        @petition.location.query.should == @updated_location[:query]
      end
    end

    context "update target with invalid information" do
      it "should alert error message when phone number is invalid" do
        put :update, target: {phone_number: "abc123", email: "abc@123.com"}, location: @updated_location, effort_id: @effort.slug, id: @target.slug
        response.should render_template :edit
        assigns(:target).errors.count.should == 1
        assigns(:target).errors.messages[:phone_number][0].should == "is invalid"
      end

      it "should alert error message when email is invalid" do
        put :update, target: {phone_number: "123456", email: "ab@#c@123.com"}, location: @updated_location, effort_id: @effort.slug, id: @target.slug
        response.should render_template :edit
        assigns(:target).errors.count.should == 1
        assigns(:target).errors.messages[:email][0].should == "is not a valid email"
      end

      it "should not update target name" do
        put :update, target: {name: "updated name"}, effort_id: @effort.slug, id: @target.slug
        Target.where(name: 'updated name', organisation_id: @organisation).first.should == nil
      end
    end
  end

  describe "#add" do
    context "user gonna to create duplicated petitions within an effort" do
      it "should not create duplicated petition" do
        Factory(:target, name: 'target name', organisation: @organisation)
        post :add, target: {name: 'target name'}, effort_id: @effort.slug
        post :add, target: {name: 'target name'}, effort_id: @effort.slug
        Petition.count.should == 1
      end

      it "should go to the page where existing petition locate" do
        Factory(:target, name: 'earlier', organisation: @organisation)
        Factory(:target, name: 'latest', organisation: @organisation)
        post :add, target: {name: 'earlier'}, effort_id: @effort.slug
        post :add, target: {name: 'latest'}, effort_id: @effort.slug
        WillPaginate.per_page = 1
        post :add, target: {name: 'earlier'}, effort_id: @effort.slug
        response.should redirect_to("#{org_effort_path(@effort.slug)}?page=2")
      end
    end
  end

  describe "remove" do
    it "should break association between effort and current petition when remove target" do
      @target = FactoryGirl.create(:target, organisation: @organisation)
      FactoryGirl.create(:target_petition, target: @target, effort: @effort, organisation: @organisation)

      delete :remove, effort_id: @effort.slug, id: @target.slug

      target = Target.first
      target.should_not be_nil
      petition = Petition.first
      petition.effort.should be_nil
    end

    it "should not crash even more than one petition are associated with the same effort and target" do
      @target = FactoryGirl.create(:target, organisation: @organisation)
      FactoryGirl.create(:target_petition, target: @target, effort: @effort, organisation: @organisation)
      FactoryGirl.create(:target_petition, target: @target, effort: @effort, organisation: @organisation)

      delete :remove, effort_id: @effort.slug, id: @target.slug

      target = Target.first
      target.should_not be_nil
      Petition.count.should == 2
    end
  end

  describe "index" do
    describe "should get filtered targets name info in json" do
      before(:each) do
        FactoryGirl.create(:target, name: 'Alpha', organisation: @organisation)
        FactoryGirl.create(:target, name: 'Alpha Romeo', organisation: @organisation)
        FactoryGirl.create(:target, name: 'Gama', organisation: @organisation)
      end

      it "should not return anything until more characters are typed" do
        get :index, effort_id: @effort.slug, term: 'a'
        Target.should_not_receive(:autocomplete)
        JSON.parse(response.body).should == []
      end

      it "should not return mid-word matches" do
        get :index, effort_id: @effort.slug, term: 'lph'
        JSON.parse(response.body).should == []
      end

      it "should return matches" do
        get :index, effort_id: @effort.slug, term: 'alph'
        JSON.parse(response.body).should == ["Alpha", "Alpha Romeo"]
      end
    end
  end
end