module Queries
  module Petitions
    class PetitionQuery < Queries::Query
      attr_reader :result
      attr_accessor :page

      validates :page, numericality: true, allow_nil: true

      def petitions
        if @result && @result.results
          @result.results
        else
          []
        end
      end

      def configuration(query)
      end

      def execute!
        if valid?
          retryable(:on => RSolr::Error::Http ) do
            @result = Petition.search do |query|
              configuration(query)
            end
          end
        else
          nil
        end
      end
    end
  end
end
