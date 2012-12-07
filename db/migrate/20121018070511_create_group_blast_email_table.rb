class CreateGroupBlastEmailTable < ActiveRecord::Migration
  def up
    create_table :group_blast_emails do |t|
      t.references :group
      t.string :from_name, null: false
      t.string :from_address, null: false
      t.string :subject, null: false
      t.text :body, null: false
      t.integer :delayed_job_id
      t.integer :recipient_count
      t.string :moderation_status, default: 'pending'
      t.string :delivery_status, default: 'pending'
      t.datetime :moderated_at
      t.text :moderation_reason

      t.timestamps
    end
  end

  def down
    drop_table :group_blast_emails
  end
end
