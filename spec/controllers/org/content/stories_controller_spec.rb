require 'spec_helper'

describe Org::Contents::StoriesController do
  include_context "setup_default_organisation"
  
  before(:each) do
    @user = Factory(:org_admin, organisation: @organisation)
    sign_in @user
  end

  describe "#index" do
    it "should assign stories and render index template" do
      get :index
      assigns(:stories).should == []
      should render_template :index
    end
  end
  
  describe "#new" do
    before(:each) do
      get :new
    end

    it { should assign_to :story }
    it { should render_template :new }
  end

  describe "#edit" do
    before(:each) do
      @story = Factory(:story, organisation: @organisation)
      get :edit, :id => @story
    end

    it { should assign_to :story }
    it { should render_template :edit }
  end

  describe "#create" do
    describe "success" do
      before(:each) do
        @story = Factory.attributes_for(:story)
        post :create, :story => @story
      end

      it { should assign_to :story }
      it { should redirect_to(org_contents_story_path(assigns(:story)))}
    end


    describe "failure" do
      before(:each) do
        post :create, :story => { title: 'title' }
      end

      it { should assign_to :story }
      it { should render_template :new }
    end
  end

  describe "#show" do
    before(:each) do
      @story = Factory(:story,  organisation: @organisation)
      get :show, :id => @story
    end

    it { should assign_to :story }
    it { should render_template :show }
  end

  describe "#update" do
    before(:each) do
      @story = Factory(:story,  organisation: @organisation)
    end

    describe "success" do
      before(:each) do
        attributes = Factory.attributes_for(:story)
        put :update, :story => attributes, :id => @story
      end

      it { should assign_to :story }
      it { should redirect_to(org_contents_story_path(assigns(:story))) }
    end


    describe "failure" do
      before(:each) do
        put :update, :story => { title: '' }, :id => @story
      end

      it { should assign_to :story }
      it { should render_template :edit }
    end

  end
end