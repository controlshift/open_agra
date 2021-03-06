module Queries
  module Petitions
    class EffortLocationQuery < PetitionQuery

      attr_accessor :organisation, :latitude, :longitude, :effort
      validates :organisation, presence: true
      validates :effort, presence: true
      validates :latitude, presence: true, numericality: true
      validates :longitude, presence: true, numericality: true

      def configuration(query)
        query.all_of do |all|
          all.with(:organisation_id, organisation.id)
          all.with(:effort_id, effort.id)
          all.with(:launched, true)
          all.with(:admin_status,[:awesome, :good])
          all.with(:cancelled, false)
          if effort.distance_limit.present?
            all.with(:location).in_radius(latitude, longitude, effort.distance_limit)
          end
        end
        query.paginate page: page, per_page: 12
        query.order_by_geodist(:location, latitude, longitude)
      end
    end
  end
end