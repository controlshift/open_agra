require 'spec_helper'
describe Org::CategoriesController do
  include_context "setup_default_organisation"

  before :each do
    @user = Factory(:org_admin, organisation: @organisation)
    sign_in @user
  end

  describe "#index" do
    it "should assign categories and render index template" do
      get :index
      assigns(:categories).should == []
      should render_template :index
    end
  end
  
  describe '#new' do
    before :each do
      get :new
    end

    it { should assign_to :category }
    it { should render_template :new }
  end

  describe '#create' do
    context 'success' do
      before :each do
        @category = Factory.attributes_for(:category)
        post :create, category: @category
      end

      it { should assign_to :category }
      it { should redirect_to(org_categories_path) }
      it 'sets flash message' do
        flash.notice.should include('has been created')
      end
    end

    context 'failure' do
      before :each do
        post :create, category: { name: '' }
      end
      
      it { should assign_to :category }
      it { should render_template :new }
    end
  end
  
  describe '#edit' do
    before :each do
      @category = Factory(:category, organisation: @organisation)
      get :edit, id: @category
    end

    it { should assign_to :category }
    it { should render_template :edit }
  end

  describe "#update" do
    before(:each) do
      @category = Factory(:category, organisation: @organisation)
      
      @category_service = mock
      CategoriesService.stub(:new) { @category_service }
    end

    describe "success" do
      before(:each) do
        attributes = { "name" => "name" }
        @category_service.should_receive(:update_attributes).with(@category, attributes) { true }
        put :update, :category => attributes, :id => @category
      end

      it { should assign_to :category }
      it { should redirect_to(org_categories_path) }
      it 'sets flash message' do
        flash.notice.should include('has been updated.')
      end
    end

    describe "failure" do
      before(:each) do
        @category_service.should_receive(:update_attributes) { false }
        put :update, :category => { name: '' }, :id => @category
      end

      it { should assign_to :category }
      it { should render_template :edit }
    end
  end
  
  describe '#destroy' do
    before :each do
      @category = Factory(:category, organisation: @organisation)
      @petition = Factory(:petition, organisation: @organisation, categories: [@category])
      delete :destroy, id: @category
      @petition.reload
    end

    specify { Category.find_by_id(@category.id).should be_nil }
    specify { @petition.categories.should be_empty }
    it { should redirect_to org_categories_path }
  end
end
