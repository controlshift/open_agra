class AddOrganisationIdToBlastEmails < ActiveRecord::Migration
  def change
    add_column :blast_emails, :organisation_id, :integer
    BlastEmail.all.each do |e|
      organisation_id = e.petition.present? ? e.petition.organisation_id : e.group.organisation_id
      e.update_column :organisation_id, organisation_id
    end
  end
end
