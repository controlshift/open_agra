module Queries
  module Exports
    class PetitionSignaturesExport < Export
      attr_accessor :petition

      def klass
        Signature
      end

      def petition_id
        ActiveRecord::Base.sanitize(petition.id)
      end

      def sql
        "SELECT id, first_name, last_name, phone_number, postcode, additional_fields FROM signatures WHERE petition_id = #{petition_id}"
      end
    end
  end
end