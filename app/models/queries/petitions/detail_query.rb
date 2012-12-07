module Queries
  module Petitions
    class DetailQuery < PetitionQuery

      attr_accessor :organisation, :search_term
      validates :organisation, presence: true
      validates :search_term, presence: true

      def configuration(query)
        query.fulltext @search_term do
          fields :title, :who, :what, :why, :delivery_details, :first_name, :last_name, :categories
          boost_fields :title => 2.0
        end
        query.all_of do |all|
          all.with(:organisation_id, @organisation.id)
          all.with(:launched, true)
          all.with(:admin_status,[:awesome, :good])
          all.with(:cancelled, false)
        end
        query.paginate page: @page, per_page: 12
        query.order_by :image_updated_at, :desc
        query.order_by :created_at, :desc
        query.facet(:category_ids)
      end
    end
  end
end