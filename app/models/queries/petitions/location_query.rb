module Queries
  module Petitions
    class LocationQuery < PetitionQuery

      attr_accessor :organisation, :latitude, :longitude, :effort, :category
      validates :organisation, presence: true
      validates :latitude, presence: true, numericality: true
      validates :longitude, presence: true, numericality: true

      def configuration(query)
        query.all_of do |all|
          all.with(:organisation_id, organisation.id)
          all.with(:launched, true)
          all.with(:admin_status,[:awesome, :good])
          all.with(:cancelled, false)
          all.with(:category_ids, category.id) if category
        end
        query.paginate page: page, per_page: 12
        query.order_by_geodist(:location, latitude, longitude)
        query.facet(:category_ids)
        query.facet(:location_country)
      end
    end
  end
end