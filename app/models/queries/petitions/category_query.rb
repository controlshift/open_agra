module Queries
  module Petitions
    class CategoryQuery < PetitionQuery

      attr_accessor :organisation, :category, :per_page
      attr_reader :category_facets
      validates :organisation, presence: true

      def categories
        if category_facets.present?
          category_ids = category_facets.rows.map { |facet| facet.value }
          Category.active(organisation.id).where(id: category_ids)
        else
          []
        end

      end

      def execute!
        if valid?
          retryable(:on => RSolr::Error::Http) do
            # we do the first query to get the overall facets
            category_facet_query = Petition.search do |query|
              configuration(query, with_category: false)
            end

            @category_facets = category_facet_query.facet(:category_ids)

            if category.present?
              # we optionally do a second query to get the results in that
              # specific category
              @result = Petition.search do |query|
                configuration(query, with_category: true)
              end
            else
              # or just fall back on the overall result set
              @result = category_facet_query
            end
          end
        else
          nil
        end
      end

      def configuration(query, options = {})
        query.all_of do |all|
          all.with(:organisation_id, organisation.id)
          all.with(:category_ids, [category.id]) if options[:with_category]
          all.without(:user_id, nil)
          all.with(:launched, true)
          all.with(:admin_status, [:awesome, :good])
          all.with(:cancelled, false)
        end
        query.paginate page: page, per_page: @per_page ? @per_page : 12
        query.order_by :image_updated_at, :desc
        query.order_by :created_at, :desc
        query.facet(:category_ids)
      end
    end
  end
end