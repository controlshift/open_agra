module Queries
  module Exports
    class MembersExport < Export
      def klass
        Signature
      end

      def sql
        combined_sql = <<SQL
  SELECT email, first_name, last_name, '' as phone_number, '' as postcode, updated_at, additional_fields
  FROM users
  WHERE join_organisation = true AND organisation_id = #{organisation_id}
  UNION
  SELECT email, first_name, last_name, phone_number, postcode, created_at AS updated_at, additional_fields
  FROM signatures
  WHERE join_organisation = true AND petition_id IN (SELECT id FROM petitions WHERE organisation_id = #{organisation_id})
SQL

        #find all users and signers who have elected to join the parent organisation.
        #chooses the latest user data
<<SQL
  SELECT members.id, combined.email, combined.first_name, combined.last_name, combined.phone_number, combined.postcode, combined.updated_at, additional_fields
  FROM members
    JOIN
      (SELECT DISTINCT ON (email) email, first_name, last_name, phone_number, postcode, updated_at, additional_fields
        FROM (
          #{combined_sql}
        ) as users
      ) AS combined
    ON (members.email = combined.email)
    WHERE members.organisation_id = #{organisation_id}
SQL
      end
    end
  end
end