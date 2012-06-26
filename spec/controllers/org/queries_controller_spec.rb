require 'spec_helper'
describe Org::QueriesController do
  include_context "setup_default_organisation"

  before :each do
    @user = Factory(:org_admin, organisation: @organisation)
    sign_in @user
  end

  describe '#new' do
    it 'should create new OrgQuery' do
      org_query = mock
      Queries::OrgQuery.should_receive(:new).with({organisation: @organisation}).and_return(org_query)

      get :new

      should render_template :new
      assigns(:org_query).should == org_query
    end
  end

  describe '#create' do

    it "should render the result or validation error" do
      @org_query = mock_model(Queries::OrgQuery)
      sql = 'select * from users'

      Queries::OrgQuery.should_receive(:new).with( {'query' => sql}).and_return(@org_query)

      @org_query.should_receive(:organisation=).with(@organisation)
      @org_query.stub(:query) { sql }
      @org_query.should_receive(:execute).and_return(true)

      post :create, queries_org_query: {query: sql}

      should render_template :new
    end

    it 'should render flash messages if execution error' do
      @org_query = double('OrgQuery null object').as_null_object
      sql = 'select * from users'

      @org_query.stub(:valid?).and_return(true)
      @org_query.should_receive(:execute).and_raise('Connection problem')
      Queries::OrgQuery.should_receive(:new).with({} ).and_return(@org_query)

      post :create, queries_org_query: {}
      should render_template :new
      flash.now[:alert].should == 'Connection problem'
    end
  end
end
