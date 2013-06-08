module Queries
  module Exports
    class PetitionSignaturesExport < Export
      attr_accessor :petition_id

      def klass
        Signature
      end

      def sql
        "SELECT signatures.id, first_name, last_name, phone_number, postcode, additional_fields, comments.text as comment FROM signatures LEFT JOIN comments ON comments.signature_id = signatures.id WHERE petition_id = #{petition_id}"
      end
    end
  end
end