module Queries
  module Exports
    class SignaturesExport < Export
      def klass
        Signature
      end

      def sql
        "SELECT #{filter_column_names(['token'])} FROM signatures WHERE petition_id IN (SELECT id FROM petitions WHERE organisation_id = #{organisation_id})"
      end
    end
  end
end