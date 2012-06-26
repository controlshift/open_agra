class AddRecipientCountToEmailBlast < ActiveRecord::Migration
  def change
    add_column :petition_blast_emails, :recipient_count, :string, :default => 0
  end
end
