class AddTargetRecipientsToBlastEmail < ActiveRecord::Migration
  def change
    add_column :blast_emails, :target_recipients, :string
  end
end
