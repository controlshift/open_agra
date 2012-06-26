module Queries
  module Petitions
    class PetitionQuery < Queries::Query
      attr_reader :result
      attr_accessor :page

      validates :page, numericality: true, allow_nil: true

      def petitions
        if @result
          @result.results
        else
          []
        end
      end

      def configuration(query)
      end

      def execute!
        if valid?
          @result = Petition.search do |query|
            configuration(query)
          end
        else
          nil
        end
      end
    end
  end
end
