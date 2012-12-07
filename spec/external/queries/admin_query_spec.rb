require 'external_helper'

describe Queries::Petitions::AdminQuery, solr: true, external: true do
  describe "AdminQuery#execute!" do
    describe "tags" do

      before(:each) do
        @organisation = Factory(:organisation)

        @petition = Factory(:petition, title: 'potential', what: 'there is space',  user: Factory(:user, organisation: @organisation), organisation: @organisation)
        @petition_with_tag = Factory(:petition, admin_notes: '#potential',  user: Factory(:user, organisation: @organisation), organisation: @organisation)
        @petition_with_word_in_notes = Factory(:petition, admin_notes: 'there is PotEntial',  user: Factory(:user, organisation: @organisation), organisation: @organisation)


        Sunspot.commit
      end

      it "should allow queries for hashtags in the beginning of the query string" do
        ps = Queries::Petitions::AdminQuery.new(search_term: '#potential')
        ps.execute!
        query_results = ps.petitions

        query_results.should include @petition_with_tag
        query_results.should_not include @petition
        query_results.should_not include @petition_with_word_in_notes
      end

      it "should strip other punctuation" do
        ps = Queries::Petitions::AdminQuery.new(search_term: 'potential%%%%')
        ps.execute!
        ps.petitions.should include @petition
        ps.petitions.should include @petition_with_word_in_notes
      end

      it "should strip white space and be case insensitive" do
        ps = Queries::Petitions::AdminQuery.new(search_term: '  poTential    ')
        ps.execute!
        ps.petitions.should include @petition
        ps.petitions.should include @petition_with_word_in_notes
      end

      it "should do a normal, everyday query" do
        ps = Queries::Petitions::AdminQuery.new(search_term: 'potential')
        ps.execute!
        ps.petitions.should include @petition
        ps.petitions.should include @petition_with_word_in_notes
      end
    end

    context "with an item in the index" do
      before(:each) do
        @organisation = Factory(:organisation)
        @other_org = Factory(:organisation)
        @petition = Factory(:petition, user: Factory(:user, organisation: @organisation), organisation: @organisation)
        @other_petition = Factory(:petition, user: Factory(:user, organisation: @other_org), organisation: @other_org)
        @orphan = Factory(:petition, user: nil, organisation: @organisation)

        Sunspot.commit
      end

      after(:each) do
        Petition.remove_all_from_index!
      end

      it "should find the petition by title" do
        ps = Queries::Petitions::AdminQuery.new search_term: @petition.title
        ps.execute!
        ps.petitions.should_not be_empty
      end

      it "should not find a string that does not exist" do
        ps = Queries::Petitions::AdminQuery.new search_term: 'Jabberwocky'
        ps.execute!
        ps.petitions.should be_empty
      end

      it "should find petitions by notes" do
        ps = Queries::Petitions::AdminQuery.new search_term: @petition.admin_notes
        ps.execute!
        ps.petitions.should_not be_empty
      end

      it "should not find petitions by notes from other organisations" do
        admin_note = 'stupendously fabulous'
        Factory(:petition, user: Factory(:user, organisation: @other_org), admin_notes: admin_note, organisation: @other_org)
        ps = Queries::Petitions::AdminQuery.new search_term: admin_note, organisation: @organisation
        ps.execute!
        ps.petitions.should be_empty
      end

      describe "searching by term and organisation" do
        before(:each) do
          @ps = Queries::Petitions::AdminQuery.new search_term: @petition.title, organisation: @organisation
          @ps.execute!
        end

        subject { @ps }

        specify { subject.result.results.should_not be_empty }
        specify { subject.result.results.should include(@petition) }
        specify { subject.result.results.should_not include(@other_petition) }

      end
    end
  end
end