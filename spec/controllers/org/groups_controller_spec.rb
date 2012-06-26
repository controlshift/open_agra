require 'spec_helper'

describe Org::GroupsController do
  include_context "setup_default_organisation"
  
  before(:each) do
    @user = Factory(:org_admin, organisation: @organisation)
    sign_in @user
  end

  describe "#index" do
    before(:each) { get :index }

    it { should assign_to :groups }
    it { should render_template :index }
  end

  describe "#new" do
    before(:each) do
      get :new
    end

    it { should assign_to :group }
    it { should render_template :new}
  end

  describe "#edit" do
    before(:each) do
      @group = Factory(:group, organisation: @organisation)
      get :edit, :id => @group.slug
    end

    it { should assign_to :group }
    it { should render_template :edit}
  end

  describe "#create" do
    describe "success" do
      before(:each) do
        @group = Factory.attributes_for(:group)
        post :create, :group => @group
      end

      it { should assign_to :group }
      it { should redirect_to(org_group_path(assigns(:group)))}
    end


    describe "failure" do
      before(:each) do
        post :create, :group => {:title => 'title'}
      end

      it { should assign_to :group }
      it { should render_template :new}
    end
  end

  describe "#show" do
    before(:each) do
      @group = Factory(:group,  organisation: @organisation)
      get :show, :id => @group
    end

    it { should assign_to :group }
    it { should render_template :show}
  end

  describe "#update" do
    before(:each) do
      @group = Factory(:group,  organisation: @organisation)
    end

    describe "success" do
      before(:each) do
        attributes = Factory.attributes_for(:group)
        put :update, :group => attributes, :id => @group.slug
      end

      it { should assign_to :group }
      it { should redirect_to(org_group_path(assigns(:group)))}
    end


    describe "failure" do
      before(:each) do
        put :update, :group => {:title => ''}, :id => @group.slug
      end

      it { should assign_to :group }
      it { should render_template :edit}
    end

  end

end
