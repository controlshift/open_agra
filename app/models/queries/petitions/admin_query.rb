module Queries
  module Petitions
    class AdminQuery < PetitionQuery
      attr_accessor :search_term, :organisation
      validates :search_term, presence: true

      def configuration(query)
        #special case searches for tags.
        if @search_term =~ /^#\w*/
          query.with :admin_notes_tags, @search_term
        else
          query.fulltext @search_term do
            fields :title, :who, :what, :why, :delivery_details, :first_name, :last_name, :categories, :admin_notes_without_tags
            boost_fields :title => 2.0
          end
        end

        query.all_of do
          with(:organisation_id, @organisation.id) if @organisation
          without(:user_id, nil)
        end
        query.paginate page: @page, per_page: 10
        query.order_by :created_at, :desc
      end
    end
  end
end
