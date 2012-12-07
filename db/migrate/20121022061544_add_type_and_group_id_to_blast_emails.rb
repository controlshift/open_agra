class AddTypeAndGroupIdToBlastEmails < ActiveRecord::Migration
  def change
    add_column :blast_emails, :type, :string
    add_column :blast_emails, :group_id, :integer
  end
end
