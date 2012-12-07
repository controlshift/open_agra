module Queries
  module Exports
    class PetitionsExport < Export
      def klass
        Petition
      end

      def sql
        "SELECT #{filter_column_names(['token', 'organisation_id'])} FROM petitions WHERE organisation_id = #{organisation_id}"
      end
    end
  end
end