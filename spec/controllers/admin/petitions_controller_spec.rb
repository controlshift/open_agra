require 'spec_helper'

describe Admin::PetitionsController do
  include_context "setup_default_organisation"
  
  it "should catch cancan exceptions" do
    controller.stub(:authenticate_user!) { raise CanCan::AccessDenied }
    get :index
    response.should redirect_to("/")
    flash[:alert].should == "You are not authorized to view that page."
  end

  context "signed in as admin" do
    before(:each) do
      sign_in Factory(:admin)
    end

    context "with a petition object" do
      before(:each) { @petition = Factory(:petition, organisation: @organisation,  user: Factory(:user, organisation: @organisation)) }

      describe "#index" do
        before(:each) { get :index }

        it { should assign_to :list }
        it { should render_template :index }
        specify { assigns[:list].petitions.should include(@petition) }
      end
    end

    describe "#search" do
      describe "for something" do
        before(:each) do
          Queries::Petitions::AdminQuery.should_receive(:new).with(search_term: 'jabberwocky', page: nil)
                                             .and_return(@admin_query = mock())
          @results = mock()
          @admin_query.should_receive(:valid?).and_return(true)
          @admin_query.should_receive(:execute!).and_return(@results)

          get :search, query: 'jabberwocky'
        end

        it { should assign_to :query }
        it { should render_template :search }
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
        response.should render_template :hot
      end
    end
  end
end
