require 'external_helper'

describe Queries::Petitions::CategoryQuery, solr: true, external: true do
  describe "#execute!" do
    context "with an item in the index" do
      before(:each) do
        @organisation = Factory(:organisation)

        @category = Factory(:category, organisation: @organisation)
        @awesome_category = Factory(:category, organisation: @organisation)

        @awesome = Factory(:petition, user: Factory(:user, organisation: @organisation), organisation: @organisation, admin_status: 'awesome', categories: [@category, @awesome_category])
        @good = Factory(:petition, user: Factory(:user, organisation: @organisation), organisation: @organisation, admin_status: 'good', categories: [@category])
        @unreviewed = Factory(:petition, user: Factory(:user, organisation: @organisation), organisation: @organisation, categories: [@category])
        @orphan = Factory(:petition, user: nil, organisation: @organisation, categories: [@category])
        
        @other_org = Factory(:organisation)
        @other_category = Factory(:category, organisation: @other_org)
        @other_petition = Factory(:petition, user: Factory(:user, organisation: @other_org), organisation: @other_org, categories: [@other_category])

        Petition.index
      end

      after(:each) do
        Petition.remove_all_from_index!
      end

      describe "a focused query for a category" do
        subject { Queries::Petitions::CategoryQuery.new(organisation: @organisation, category: @category) }
      
        specify{ subject.valid?.should be_true }

        context "when executed" do
          before(:each) { subject.execute! }

          specify { subject.petitions.should  include(@awesome)}
          specify { subject.petitions.should  include(@good)}
          specify { subject.petitions.should_not include(@unreviewed)}
          specify { subject.petitions.should_not include(@other_petitition)}
          specify { subject.petitions.should_not  include(@orphan)}
          specify { subject.categories.should include(@category)}
          specify { subject.categories.should include(@awesome_category)}
          specify { subject.categories.should_not include(@other_category)}
        end
      end

      describe "an overall directory query" do
        subject { Queries::Petitions::CategoryQuery.new(organisation: @organisation) }

        specify{ subject.valid?.should be_true }

        context "when executed" do
          before(:each) { subject.execute! }

          specify { subject.petitions.should  include(@awesome)}
          specify { subject.petitions.should  include(@good)}
          specify { subject.petitions.should_not include(@unreviewed)}
          specify { subject.petitions.should_not include(@other_petitition)}
          specify { subject.petitions.should_not  include(@orphan)}
          specify { subject.categories.should include(@category)}
          specify { subject.categories.should include(@awesome_category)}
          specify { subject.categories.should_not include(@other_category)}
        end
      end

      describe "pagination with 50 results per page for a category" do
        subject {Queries::Petitions::CategoryQuery.new(organisation: @organisation, category: @category)}

        context "when executed" do
          before(:each) {
            subject.per_page = 50
            subject.execute!
          }

          specify {subject.petitions.per_page.should eql(50)}
        end
      end
    end
  end
end
