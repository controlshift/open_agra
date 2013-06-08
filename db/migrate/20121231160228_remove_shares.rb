class RemoveShares < ActiveRecord::Migration
  def up
    execute "DROP TABLE IF EXISTS shares"
  end

  def down
    create_table :shares do |t|
      t.string  :code, length: 16
      t.integer :facebook_share_variant_id
      t.integer :petition_id
      t.hstore  :session_store
      t.timestamps
    end

    add_index :shares, :code, :unique => true
  end
end
