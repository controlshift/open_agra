class SmarterIndexesUsingMoreMagic < ActiveRecord::Migration
  def up
    execute "drop index if exists index_signatures_on_email_and_petition_id_and_deleted_at"
    remove_index(:users, [:email, :organisation_id])
    execute "CREATE UNIQUE INDEX lower_case_signatures_email ON signatures (lower(email), petition_id, deleted_at);"
    execute "CREATE UNIQUE INDEX lower_case_users_email ON users (lower(email), organisation_id);"
    execute "CREATE INDEX recent_signatures_desc ON signatures USING btree (created_at DESC, petition_id , deleted_at NULLS LAST );"
  end

  def down
    add_index :signatures, [:email, :petition_id, :deleted_at], :unique => true
    add_index(:users, [:email, :organisation_id], :unique => true)
    execute "drop index if exists lower_case_signatures_email;"
    execute "drop index if exists lower_case_users_email;"
    execute "drop index if exists recent_signatures_desc;"
  end
end
