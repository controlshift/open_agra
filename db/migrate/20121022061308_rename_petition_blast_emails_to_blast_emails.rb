class RenamePetitionBlastEmailsToBlastEmails < ActiveRecord::Migration
  def up
    rename_table :petition_blast_emails, :blast_emails
  end

  def down
    rename_table :blast_emails, :petition_blast_emails
  end
end
