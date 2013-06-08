module Queries
  module Exports
    class MembersForGroupExport < Export
      attr_accessor :group_id

      def klass
        Signature
      end

      def sql
        "SELECT id, email, first_name, last_name, phone_number, postcode, created_at, additional_fields FROM signatures
         WHERE petition_id IN (SELECT petitions.id FROM petitions WHERE petitions.organisation_id = #{organisation_id} AND petitions.group_id = #{group_id})
         AND join_group = true AND join_organisation = true"
      end
    end
  end
end