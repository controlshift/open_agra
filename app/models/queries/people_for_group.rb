module Queries
  class PeopleForGroup
    def people_as_csv(group_id)
      signatures = Signature.joins(:petition).where(join_organisation: true).where(Petition.arel_table[:group_id].eq(group_id))

      CSV.generate do |csv|
        csv << ["Email", "First Name", "Last Name", "Phone Number", "Postcode", "Created At"]
        signatures.each do |person|
          csv << [person.email, person.first_name, person.last_name, person.phone_number, person.postcode, format_date(person.created_at)]
        end
      end
    end

    def format_date(value)
      value.is_a?(DateTime) ? value.strftime("%Y-%m-%d %H:%M:%S") : value
    end
  end
end