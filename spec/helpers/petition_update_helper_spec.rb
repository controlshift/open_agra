require 'spec_helper'

describe PetitionUpdateHelper do

  describe "#update" do
    let(:petition) { Factory.build(:petition) }
    let(:location) { Factory.build(:location) }
    let(:petition_attributes) { {} }

    it 'updates petition and returns true if no location and no petition update errors' do
      helper.should_receive(:attributes_for_petition).with(petition.attributes).and_return(petition_attributes)
      helper.should_receive(:attributes_for_categorized_petitions).with(petition, petition.attributes[:category_ids])
      PetitionsService.should_receive(:new).and_return(service = mock)
      service.should_receive(:update_attributes).with(petition, petition_attributes).and_return(true)
      Location.should_not_receive(:find_by_query)

      helper.update_petition(petition, petition.attributes).should be_true
    end

    it 'returns false if something wrong happened while updating the petition' do
      helper.should_receive(:attributes_for_petition).with(petition.attributes).and_return(petition_attributes)
      helper.should_receive(:attributes_for_categorized_petitions).with(petition, petition.attributes[:category_ids])
      Location.should_not_receive(:find_by_query)
      PetitionsService.should_receive(:new).and_return(service = mock)
      service.should_receive(:update_attributes).with(petition, petition_attributes).and_return(false)

      helper.update_petition(petition, petition.attributes).should be_false
    end

    it 'updates petition as well as creating or finding a given location' do
      helper.should_receive(:attributes_for_petition).with(petition.attributes).and_return(petition_attributes)
      helper.should_receive(:attributes_for_categorized_petitions).with(petition, petition.attributes[:category_ids])
      Location.should_receive(:find_by_query).with(location.attributes['query']).and_return(location)
      PetitionsService.should_receive(:new).and_return(service = mock)
      service.should_receive(:update_attributes).with(petition, petition_attributes).and_return(true)

      helper.update_petition(petition, petition.attributes, location.attributes).should be_true
    end 

    it 'does not update petition if a location error occurs' do
      helper.should_receive(:attributes_for_petition).with(petition.attributes).and_return(petition_attributes)
      helper.should_receive(:attributes_for_categorized_petitions).with(petition, petition.attributes[:category_ids])
      helper.should_receive(:update_location).with(location.attributes, petition_attributes).and_return(false)

      PetitionsService.should_not_receive(:new)

      helper.update_petition(petition, petition.attributes, location.attributes).should be_false
    end
  end
end
