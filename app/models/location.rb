# == Schema Information
#
# Table name: locations
#
#  id          :integer         not null, primary key
#  query       :string(255)
#  latitude    :decimal(13, 10)
#  longitude   :decimal(13, 10)
#  street      :string(255)
#  locality    :string(255)
#  postal_code :string(255)
#  country     :string(255)
#  region      :string(255)
#  warning     :string(255)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#  extras      :text
#

class Location < ActiveRecord::Base
  store :extras, accessors: [:types]
  
  validates_presence_of :query, :latitude, :longitude
  validates_uniqueness_of :query
  
  #searchable do
  #  text :query, :country, :region, :locality, :street, :postal_code
  #  latlon(:location) { Sunspot::Util::Coordinates.new(latitude, longitude) }
  #end

  def formatted_string(options = {})
    separator = options[:separator] ? options[:separator] : "\n"

    response = ""
    response << "#{street} #{separator}" if street.present?
    response << "#{locality}, #{region} "
    response << postal_code if postal_code.present?
    response.html_safe
  end

  def lat
    latitude
  end

  def lng
    longitude
  end

  def zoom
    return 11 if street.present?
    return 9  if locality.present?
    return 6  if region.present?
    return 4  if country.present?
    return 3
  end
end
