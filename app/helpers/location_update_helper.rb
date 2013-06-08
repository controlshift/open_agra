module LocationUpdateHelper

  def update_location(location_attributes, attributes)
    location_status = true
    if location_attributes.present? && (location_attributes['latitude'].present? || location_attributes['kml'].present?) 
      location = (location_attributes['query'].present? && Location.find_by_query(location_attributes['query'])) || Location.create(location_attributes)
      attributes[:location_id] = location.id
      location_status = location.valid?
    end
    location_status
  end

end

