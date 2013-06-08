require 'spec_helper'

describe Org::EffortsController do
  include_context "setup_default_organisation"

  before(:each) do
    @user = Factory(:org_admin, organisation: @organisation)
    sign_in @user
  end

  describe "#index" do
    before(:each) { get :index }

    it { should assign_to :efforts }
    it { should render_template :index }
  end

  describe "#new" do
    before(:each) do
      get :new
    end

    it { should assign_to :effort }
    it { should render_template :new }
  end

  describe "#edit" do
    before(:each) do
      @effort = Factory(:effort, organisation: @organisation)
      get :edit, id: @effort.slug
    end

    it { should assign_to :effort }
    it { should render_template :edit }
  end

  describe "#create" do
    describe "success" do
      before(:each) do
        @effort = Factory.attributes_for(:effort)
        post :create, effort: @effort
      end

      it { should assign_to :effort }
      it { should redirect_to(org_effort_path(assigns(:effort))) }
    end

    describe "failure" do
      before(:each) do
        post :create, effort: {title: 'title'}
      end

      it { should assign_to :effort }
      it { should render_template :new }
    end
  end

  describe "#show" do
    shared_context "render open ended effort" do
      it { should assign_to :effort }
      it { should assign_to :petitions }
      it { should render_template :show }
    end

    context "open ended effort" do
      include_context "render open ended effort"

      before(:each) do
        @effort = Factory(:effort, organisation: @organisation)
        get :show, id: @effort
      end
    end
  end

  describe "#update" do
    before(:each) do
      @effort = Factory(:effort, organisation: @organisation)
    end

    describe "success" do
      before(:each) do
        attributes = Factory.attributes_for(:effort)
        put :update, effort: attributes, id: @effort.slug
      end

      it { should assign_to :effort }
      it { should redirect_to(org_effort_path(assigns(:effort))) }
    end


    describe "failure" do
      before(:each) do
        put :update, effort: {title: ''}, id: @effort.slug
      end

      it { should assign_to :effort }
      it { should render_template :edit }
    end

  end

end
