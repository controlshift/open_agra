module PetitionUpdateHelper
  include PetitionAttributesHelper
  include LocationUpdateHelper
  
  def update_petition(petition, petition_attributes, location_attributes = {})
    petition_attrs = attributes_for_petition(petition_attributes)
    new_petition_category_attributes = attributes_for_categorized_petitions(petition, petition_attributes[:category_ids])
    petition_attrs[:categorized_petitions_attributes] = new_petition_category_attributes if new_petition_category_attributes.present?

    location_status = update_location(location_attributes, petition_attrs)

    if params[:location_kind].present? && params[:location_kind] == 'national'
      petition_attrs[:location_id] = nil
    end
    
    location_status && PetitionsService.new.update_attributes(petition, petition_attrs)
  end
end