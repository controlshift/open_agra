require 'spec_helper'


def mock_query_petitions(petitions)
  @CURRENT_PAGE = 2
  @TOTAL_PAGE = 2
  @NEXT_PAGE = nil
  @PREVIOUS_PAGE = 1
  petitions.stub(:current_page) { @CURRENT_PAGE }
  petitions.stub(:total_pages) { @TOTAL_PAGE }
  petitions.stub(:next_page) { @NEXT_PAGE }
  petitions.stub(:previous_page) { @PREVIOUS_PAGE }
  petitions
end

def create_featured_petition
  featured_petition = Factory(:petition, admin_status: 'good', organisation: @organisation)
  Factory(:signature, petition: featured_petition)
  featured_petition
end

def petition_info(petition)
  {'title' => petition.title,
   'id' => petition.id,
   'slug' => petition.slug,
   'url' => petition_url(petition),
   'creator_name' => petition.user.full_name,
   'created_at' => petition.created_at.iso8601,
   'last_signed_at' => petition.signatures.last.created_at.iso8601,
   'signature_count' => petition.signatures.size,
   'goal' => petition.goal,
   'target' => petition.who,
   'why' => petition.why.truncate(200)}
end

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

    describe "API methods" do
      describe "for category list info" do
        before(:each) do
          @featured_petition = Factory(:petition, admin_status: 'good', organisation: @organisation)
          @category = Factory(:category, organisation: @organisation, petitions: [@featured_petition])

          query.stub(:categories) { [@category] }
          Queries::Petitions::CategoryQuery.stub(:new).with(page: nil, organisation: @organisation) { query }
          query.should_receive(:execute!)
        end

        it "should get categories info in json" do
          get :index, {format: "json"}
          JSON.parse(response.body).should == [{'category_name' => @category.name, 'category_count' => 1}]
        end

        it "should respond to jsonp requests" do
          get :index, {format: "json", callback: 'foo'}
          response.body.should =~ /^foo/
        end
      end

      describe "for category petition list" do
        before(:each) do
          @petition1 = create_featured_petition()
          @petition2 = create_featured_petition()
          petitions = [@petition1, @petition2]
          @category = Factory(:category, organisation: @organisation, petitions: [@petition1, @petition2])

          Category.should_receive(:find_by_slug!).and_return(@category)
          query.stub(:petitions) { mock_query_petitions(petitions) }
          Queries::Petitions::CategoryQuery.stub(:new).with(page: nil, organisation: @organisation, category: @category) { query }
          query.should_receive(:per_page=).with(50)
          query.should_receive(:execute!)
        end

        it "should get all petitions in a given category in json" do
          get :show, {format: "json", category: "slug", id: @category}
          JSON.parse(response.body).should == {'current_page' => @CURRENT_PAGE,
                                   'total_pages' => @TOTAL_PAGE,
                                   'previous_page' => @PREVIOUS_PAGE,
                                   'next_page' => @NEXT_PAGE,
                                   'name' =>@category.name,
                                   'results' => [petition_info(@petition1),
                                             petition_info(@petition2)]}
        end

        it "should respond to jsonp requests" do
          get :show, {format: "json", category: "slug", id: @category, callback: 'foo'}
          response.body.should =~ /^foo/
        end
      end

      describe "truncate the long description" do
        it "should truncate the why" do
          petition = Factory(:petition, admin_status: 'good', organisation: @organisation, why: "w"*230)
          Factory(:signature, petition: petition)
          petitions = [petition]
          category = Factory(:category, organisation: @organisation, petitions: petitions)

          Category.should_receive(:find_by_slug!).and_return(category)
          query.stub(:petitions) { mock_query_petitions(petitions) }
          Queries::Petitions::CategoryQuery.stub(:new).with(page: nil, organisation: @organisation, category: category) { query }
          query.should_receive(:per_page=).with(50)
          query.should_receive(:execute!)

          get :show, {format: "json", category: "slug", id: category}
          response.body.should have_content "w"*197+"..."
        end
      end
    end
  end
end
