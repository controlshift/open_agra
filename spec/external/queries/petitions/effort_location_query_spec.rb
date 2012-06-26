require 'external_helper'

describe Queries::Petitions::EffortLocationQuery, solr: true, external: true do
  describe "#execute!" do
    context "with an item in the index" do
      # search at TownHall
      subject { Queries::Petitions::EffortLocationQuery.new(organisation: @organisation, latitude: -33.873756, longitude: 151.206797, effort: @effort) }
      
      before(:each) do
        @organisation = Factory(:organisation)
        @location = Factory(:location, latitude: -33.873756, longitude: 151.206797)
        @effort = Factory(:effort, organisation: @organisation)
      end

      after(:each) do
        Petition.remove_all_from_index!
      end
      
      describe "nearby search" do
        before :each do
          user = Factory(:user, organisation: @organisation)
          @wynyard = Factory(:petition, user: user, organisation: @organisation, location: Factory(:location, latitude: -33.86581, longitude: 151.205478), admin_status: :awesome, effort: @effort)
          @museum = Factory(:petition, user: user, organisation: @organisation, location: Factory(:location, latitude: -33.876473, longitude: 151.209683), admin_status: :awesome, effort: @effort)
          @manly = Factory(:petition, user: user, organisation: @organisation, location: Factory(:location, latitude: -33.797944, longitude: 151.285686), admin_status: :awesome, effort: @effort)
          Petition.index
        end
        
        it "should return petitions ordered by location" do
          subject.execute!
          subject.petitions[0].should == @museum
          subject.petitions[1].should == @wynyard
          subject.petitions[2].should == @manly
        end
      end
      
      describe "admin_status" do
        [:awesome, :good].each do |admin_status|
          describe "search good petition" do
            before :each do
              @petition = Factory(:petition, user: Factory(:user, organisation: @organisation), organisation: @organisation, location: @location, admin_status: admin_status, effort: @effort)
              Petition.index
              subject.execute!
            end

            specify { subject.petitions.should  include(@petition) }
          end
        end

        describe 'search approved petition' do
          before :each do
            @petition = Factory(:petition, user: Factory(:user, organisation: @organisation), organisation: @organisation, location: @location, admin_status: :approved, effort: @effort)
            Petition.index
            subject.execute!
          end

          specify { subject.petitions.should_not  include(@petition) }
        end

        [:inappropriate, :unreviewed].each do |admin_status|
          describe "search bad petition" do
            before :each do
              @petition = Factory(:petition, user: Factory(:user, organisation: @organisation), organisation: @organisation, location: @location, admin_status: admin_status, admin_reason: "RubyMotion")
              Petition.index
              subject.execute!
            end

            specify { subject.petitions.should_not include(@petition)}
          end
        end
      end
      
      describe "unlaunched petition" do
        before :each do
          @unlaunched = Factory(:petition, user: Factory(:user, organisation: @organisation), organisation: @organisation, location: @location, launched: false)
          Petition.index
          subject.execute!
        end
        
        specify { subject.petitions.should_not include(@unlaunched) }
      end
      
      describe "cancelled petition" do
        before :each do
          @cancel = Factory(:petition, user: Factory(:user, organisation: @organisation), organisation: @organisation, location: @location, cancelled: true)
          Petition.index
          subject.execute!
        end
        
        specify { subject.petitions.should_not include(@cancel) }
      end
      
      describe "orphan petition" do
        before :each do
          @orphan = Factory(:petition, user: nil, organisation: @organisation, location: @location)
          Petition.index
          subject.execute!
        end
        
        specify { subject.petitions.should_not include(@orphan) }
      end
      
      describe "another organisation petition" do
        before :each do
          @other_org = Factory(:organisation)
          @other_petition = Factory(:petition, user: Factory(:user, organisation: @other_org), organisation: @other_org, location: @location)
          Petition.index
          subject.execute!
        end
        
        specify { subject.petitions.should_not include(@other_petition) }
      end

      describe "another effort petition" do
        before :each do
          @other_effort = Factory(:effort, organisation: @organisation)
          @other_petition = Factory(:petition, user: Factory(:user, organisation: @organisation), organisation: @organisation, admin_status: :awesome, location: @location, effort: @other_effort)

          Petition.index
          subject.execute!
        end

        specify { subject.petitions.should_not include(@other_petition) }
      end
    end
  end
end
