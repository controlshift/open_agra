require 'spec_helper'

describe Queries::ClusteredPetitionsQuery do

  describe "#locations_as_json" do
    context "without a category" do
      before do
        @organisation = Factory(:organisation)
        @location = Factory(:location)
        @petition = Factory(:petition, organisation: @organisation, location: @location, admin_status: :good)
      end
      it "should return json for all petition locations" do
        json1 = Queries::ClusteredPetitionsQuery.new(organisation: @organisation).locations_as_json

        queries = @organisation.petitions.appropriate.map(&:location).map(&:query)
        result = JSON.parse(json1).map{|j| j['query']}

        result.should == queries
        result.should_not be_empty
      end
    end
  end


  describe "#clustered_locations_as_json" do
    context "without a category" do
      before do
        @organisation = Factory(:organisation)
        @location = Factory(:location)
        @petition = Factory(:petition, organisation: @organisation, location: @location, admin_status: :good)
      end
      it "should return json for all petition locations" do
        json1 = Queries::ClusteredPetitionsQuery.new(organisation: @organisation).clustered_locations_as_json

        queries = @organisation.petitions.appropriate.map(&:location).map(&:query)
        result = JSON.parse(json1).first['locations'].map{|j| j['query']}

        result.should == queries
        result.should_not be_empty
      end
    end
    context "with a category" do
      before do
        @organisation = Factory(:organisation)
        @location = Factory(:location)
        @petition = Factory(:petition, organisation: @organisation, location: @location, admin_status: :good)
        @category = Factory(:category)
        @petition2 = Factory(:petition, organisation: @organisation, location: @location, admin_status: :good, categories: [@category])
      end
      it "should return json for all category petition locations" do
        json1 = Queries::ClusteredPetitionsQuery.new(organisation: @organisation, category: @category).clustered_locations_as_json

        queries = @category.petitions.appropriate.map(&:location).map(&:query)
        result = JSON.parse(json1).first['locations'].map{|j| j['query']}

        result.should == queries
        result.should_not be_empty
      end
    end
    context "with a country" do
      before do
        @organisation = Factory(:organisation)
        @location = Factory(:location, :country => 'AU')
        @petition = Factory(:petition, organisation: @organisation, location: @location, admin_status: :good)
        @location2 = Factory(:location, :country => 'US')
        @petition2 = Factory(:petition, organisation: @organisation, location: @location2, admin_status: :good)
      end
      it "should return json for all country petition locations" do
        json1 = Queries::ClusteredPetitionsQuery.new(organisation: @organisation, country: @location.country).clustered_locations_as_json
        queries = [@petition].map(&:location).map(&:query)
        result = JSON.parse(json1).first['locations'].map{|j| j['query']}

        result.should == queries
        result.should_not be_empty
      end
    end
  end
end
