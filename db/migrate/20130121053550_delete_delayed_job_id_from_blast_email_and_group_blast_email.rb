class DeleteDelayedJobIdFromBlastEmailAndGroupBlastEmail < ActiveRecord::Migration
  def up
  	remove_column :blast_emails, :delayed_job_id
  	remove_column :group_blast_emails, :delayed_job_id
  end

  def down
  	add_column :group_blast_emails, :delayed_job_id, :integer
  	add_column :blast_emails, :delayed_job_id, :integer
  end
end
