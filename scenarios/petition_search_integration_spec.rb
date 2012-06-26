require File.dirname(__FILE__) + '/scenario_helper.rb'


describe Petition do
  describe "searching" do
    context "with an item in the index" do
      before(:each) do
        @petition = Factory(:petition, user: Factory(:user))
        @petition.solr_index!
      end

      it "should find the petition by title" do
        title = @petition.title
        petition_search = Petition.search do
          fulltext title
        end
        petition_search.results.should_not be_empty
      end

      it "should find the petition by first name" do
        first_name = @petition.first_name
        petition_search = Petition.search do
          fulltext first_name
        end
        petition_search.results.should_not be_empty
      end

      it "should find the petition by last name" do
        last_name = @petition.last_name
        petition_search = Petition.search do
          fulltext last_name
        end
        petition_search.results.should_not be_empty
      end

      it "should find the petition by created at" do
        created_at = @petition.created_at
        petition_search = Petition.search do
          with :created_at, created_at
        end
        petition_search.results.should_not be_empty
      end

      it "should find the petition by organisation id" do
        organisation_id = @petition.organisation_id
        petition_search = Petition.search do
          with :organisation_id, organisation_id
        end
        petition_search.results.should_not be_empty
      end

      it "should not find a string that does not exist" do
        ps = Petition.search do
          fulltext 'Jabberwock'
        end
        ps.results.should be_empty
      end

      it 'should find a petition based on the user email addy' do
        email =  @petition.user.email
        ps = Petition.search do
          fulltext email
        end
        ps.results.should_not be_empty
      end
    end
  end
end