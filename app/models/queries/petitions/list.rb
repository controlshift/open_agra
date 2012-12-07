module Queries
  module Petitions
    class List < Queries::Query
      attr_accessor :sort_column, :sort_direction, :conditions, :page
      validates :sort_column, presence: true, inclusion: Petition.column_names + ['signatures_count', 'petition_flags_count']
      validates :sort_direction, presence: true, inclusion: %w[asc desc]

      def initialize(attrs = {})
        super

        self.sort_direction = 'desc' if sort_direction.blank?
        self.sort_column = 'created_at' if sort_column.blank?
      end

      def petitions
        unless defined? @_petitions
          if valid?
            query = Petition.launched.includes(:user)
                                           .order((sort_column + " " + sort_direction))
                                           .paginate(page: page, conditions: conditions)

            if sort_column == "signatures_count"
              @_petitions = query.join_and_includes_signatures_count
                          .includes_petition_flags_count
            elsif sort_column == "petition_flags_count"
              @_petitions = query.join_and_includes_petition_flags_count
                          .includes_signatures_count
            else
              @_petitions = query.includes_signatures_count
                          .includes_petition_flags_count
            end

          else
            @_petitions = Petition.launched.includes(:user)
                           .order("created_at desc")
                           .paginate(page: page, conditions: conditions)
                           .includes_signatures_count
                           .includes_petition_flags_count
          end
        end
        return @_petitions
      end
    end
  end
end