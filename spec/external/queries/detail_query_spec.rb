require 'external_helper'

describe Queries::Petitions::DetailQuery, solr: true, external: true do
  describe "#execute!" do
    context "with an item in the index" do
      before(:each) do
        @organisation = Factory(:organisation)
        @category = Factory(:category, organisation: @organisation)
        @petition = Factory(:petition, user: Factory(:user, organisation: @organisation), organisation: @organisation, admin_status: 'awesome', admin_notes: "admin note", categories: [@category])
        @unreviewed = Factory(:petition, user: Factory(:user, organisation: @organisation), organisation: @organisation)
        @orphan = Factory(:petition, user: nil, organisation: @organisation)
        
        @other_org = Factory(:organisation)
        @other_petition = Factory(:petition, user: Factory(:user, organisation: @other_org), organisation: @other_org)
        
        Petition.index
      end

      after(:each) do
        Petition.remove_all_from_index!
      end
      
      shared_examples_for "petition can be found" do
        before(:each) { subject.execute! }

        specify { subject.petitions.should  include(@petition)}
        specify { subject.petitions.should_not include(@unreviewed)}
        specify { subject.petitions.should_not include(@other_petitition)}
        specify { subject.petitions.should_not include(@orphan)}
      end

      describe "search good petition" do
        before(:each) do
          @petition.admin_status = :good
          @petition.save
          Sunspot.commit
        end
        subject { Queries::Petitions::DetailQuery.new(organisation: @organisation, search_term: @petition.title) }
        it_should_behave_like "petition can be found"
      end

      describe "search awesome petition" do
        before(:each) do
          @petition.admin_status = :awesome
          @petition.save
          Sunspot.commit
        end
        subject { Queries::Petitions::DetailQuery.new(organisation: @organisation, search_term: @petition.title) }
        it_should_behave_like "petition can be found"
      end
      
      describe "search by title" do
        subject { Queries::Petitions::DetailQuery.new(organisation: @organisation, search_term: @petition.title) }
        it_should_behave_like "petition can be found"
      end
      
      describe "search by who" do
        subject { Queries::Petitions::DetailQuery.new(organisation: @organisation, search_term: @petition.who) }
        it_should_behave_like "petition can be found"
      end
      
      describe "search by what" do
        subject { Queries::Petitions::DetailQuery.new(organisation: @organisation, search_term: @petition.what) }
        it_should_behave_like "petition can be found"
      end
      
      describe "search by why" do
        subject { Queries::Petitions::DetailQuery.new(organisation: @organisation, search_term: @petition.why) }
        it_should_behave_like "petition can be found"
      end
      
      describe "search by delivery_details" do
        subject { Queries::Petitions::DetailQuery.new(organisation: @organisation, search_term: @petition.delivery_details) }
        it_should_behave_like "petition can be found"
      end
      
      describe "search by category" do
        subject { Queries::Petitions::DetailQuery.new(organisation: @organisation, search_term: @category.name) }
        it_should_behave_like "petition can be found"
      end
      
      shared_examples_for "no petition can be found" do
        before(:each) { subject.execute! }

        specify { subject.petitions.should_not  include(@petition)}
        specify { subject.petitions.should_not include(@unreviewed)}
        specify { subject.petitions.should_not include(@other_petitition)}
        specify { subject.petitions.should_not include(@orphan)}
      end
      
      describe "search by email" do
        subject { Queries::Petitions::DetailQuery.new(organisation: @organisation, search_term: @petition.user.email) }
        it_should_behave_like "no petition can be found"
      end
      
      describe "search by admin note" do
        subject { Queries::Petitions::DetailQuery.new(organisation: @organisation, search_term: @petition.admin_notes) }
        it_should_behave_like "no petition can be found"
      end

      describe "search approved petition" do
        before(:each) do
          @petition.admin_status = :approved
          @petition.save!
          Sunspot.commit
        end
        subject { Queries::Petitions::DetailQuery.new(organisation: @organisation, search_term: @petition.title) }
        it_should_behave_like "no petition can be found"
      end

      describe "search inappropriate petition" do
        before(:each) do
          @petition.admin_status = :inappropriate
          @petition.admin_reason = 'foo'
          @petition.save!
          Sunspot.commit

        end
        subject { Queries::Petitions::DetailQuery.new(organisation: @organisation, search_term: @petition.title) }
        it_should_behave_like "no petition can be found"
      end
    end
  end
end
