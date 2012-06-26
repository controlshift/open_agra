module Queries
  class People
    def people_to_export(organisation_id)
      #find all users and signers who have elected to join the parent organisation.
      #chooses the latest user data
      organisation_id = ActiveRecord::Base.sanitize(organisation_id)
      sql = <<SQL
SELECT DISTINCT ON (email) email, first_name, last_name, phone_number, postcode, updated_at
FROM (SELECT email, first_name, last_name, '' as phone_number, '' as postcode, updated_at
FROM users
WHERE join_organisation = true AND organisation_id = #{organisation_id}
UNION
SELECT email, first_name, last_name, phone_number, postcode, created_at AS updated_at
FROM signatures
WHERE join_organisation = true AND petition_id IN (SELECT id FROM petitions WHERE organisation_id = #{organisation_id})
) AS users
ORDER BY email, updated_at DESC
SQL
      ActiveRecord::Base.connection.execute(sql)
    end

    def people_as_csv(organisation_id)
      record_set = people_to_export(organisation_id)

      csv_string = CSV.generate do |csv|
        csv << ["Email", "First Name", "Last Name", "Phone Number", "Postcode", "Updated At"]
        record_set.each do |person|
          csv << person.keys.collect {|c| format_date(person[c])}
        end
      end
    end

    def format_date(value)
      value.is_a?(DateTime) ? value.strftime("%Y-%m-%d %H:%M:%S") : value
    end
  end
end