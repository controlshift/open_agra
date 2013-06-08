module Queries
  module Petitions
    class CountryQuery < PetitionQuery

      attr_accessor :organisation, :country, :category
      validates :organisation, presence: true
      validates :country, presence: true

      def configuration(query)
        query.all_of do |all|
          all.with(:organisation_id, organisation.id)
          all.with(:launched, true)
          all.with(:admin_status,[:awesome, :good])
          all.with(:cancelled, false)
          all.with(:category_ids, category.id) if category
          all.with(:location_country, country)
        end
        query.paginate page: page, per_page: 12
        query.facet(:category_ids)
      end
    end
  end
end