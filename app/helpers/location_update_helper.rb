module LocationUpdateHelper

  def update_location(location_attributes, attributes)
    location_status = true
    if location_attributes.present? && location_attributes['latitude'].present?
      location = Location.find_or_create_by_query(location_attributes[:query], location_attributes)
      attributes[:location_id] = location.id
      location_status = location.valid?
    end
    location_status
  end

end

