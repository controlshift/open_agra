module Queries
  module Exports
    class SignaturesExport < Export
      def klass
        Signature
      end

      def sql
        "SELECT #{filter_column_names(['token', 'akid'])}, comments.text as comment FROM signatures LEFT JOIN comments ON comments.signature_id = signatures.id WHERE petition_id IN (SELECT id FROM petitions WHERE organisation_id = #{organisation_id})"
      end
    end
  end
end