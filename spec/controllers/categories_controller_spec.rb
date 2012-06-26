require 'spec_helper'

describe CategoriesController do
  include_context "setup_default_organisation"

  describe "#index" do
    let(:query) { mock }
    
    it "should show featured campaigns" do
      query.stub(:result) { nil }
      Queries::Petitions::CategoryQuery.stub(:new).with(page: nil, organisation: @organisation) { query }
      query.should_receive(:execute!)
      get :index
      response.should render_template :index
    end
    
    it "should show campaigns in category" do
      category = Factory(:category, organisation: @organisation)
      Category.should_receive(:find_by_slug!).and_return(category)
      query.stub(:result) { nil }
      Queries::Petitions::CategoryQuery.stub(:new).with(page: nil, organisation: @organisation, category: category) { query }
      query.should_receive(:execute!)

      
      get :show, category: "slug", id: category
      response.should render_template :index
    end
  end
end
