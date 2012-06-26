class AddAdminReasonAndAdministratedAtColumnsToPetition < ActiveRecord::Migration
  def change
    add_column :petitions, :admin_reason, :text
    add_column :petitions, :administered_at, :timestamp
    Petition.update_all(["admin_reason = 'A default reason set by the migration'"], ["admin_status = 'inappropriate'"])
    Petition.update_all(["administered_at = ?", Time.now], ["admin_status != 'unreviewed' AND administered_at IS NOT NULL"])
  end
end
