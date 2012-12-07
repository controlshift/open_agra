class AddIndexesForAdminViews < ActiveRecord::Migration
  def up
    add_index :petitions, [:organisation_id, :user_id]
    execute "CREATE INDEX existing_signatures ON signatures (petition_id) WHERE (deleted_at is null)"
    execute "CREATE INDEX org_petitions ON petitions (organisation_id, created_at) WHERE (user_id IS NOT NULL)"

  end

  def down
    remove_index :petitions, [:organisation_id, :user_id]
    execute "DROP INDEX existing_signatures"
    execute "DROP INDEX org_petitions"
  end
end
