require 'spec_helper'

describe Petitions::LocationsController do
  include_context "setup_default_organisation"

  describe '#locations' do
    let (:q) do
      m = mock()
      m.stub(:locations_as_json).and_return("{}")
      m
    end

    it 'should get organization petition location as json' do
      Queries::ClusteredPetitionsQuery.should_receive(:new).and_return(q)
      get :index
    end
    it 'should get get locations in a category' do
      @category = Factory(:category)
      Queries::ClusteredPetitionsQuery.should_receive(:new).with(organisation: @organisation, category: @category, country: nil).and_return(q)
      get :index, category: @category.slug
    end
    it 'should get get locations in a country' do
      @category = Factory(:category)
      Queries::ClusteredPetitionsQuery.should_receive(:new).with(organisation: @organisation, country: 'AU', :category => nil).and_return(q)
      get :index, country: 'AU'
    end
  end
end
