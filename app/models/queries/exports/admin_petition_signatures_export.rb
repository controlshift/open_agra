module Queries
  module Exports
    class AdminPetitionSignaturesExport < Export
      attr_accessor :petition_id

      def klass
        Signature
      end

      def sql
        "SELECT #{filter_column_names(['token', 'akid'])}, comments.text as comment FROM signatures LEFT JOIN comments ON signatures.id = comments.signature_id WHERE petition_id = #{petition_id}"
      end
    end
  end
end