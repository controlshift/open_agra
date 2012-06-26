class AddModerationToEmail < ActiveRecord::Migration
  def change
    add_column :petition_blast_emails, :moderation_status, :string, :default => 'pending'
    add_column :petition_blast_emails, :delivery_status,   :string, :default => 'pending'
    add_column :petition_blast_emails, :moderated_at,      :datetime
    add_column :petition_blast_emails, :moderation_reason, :string
  end
end
