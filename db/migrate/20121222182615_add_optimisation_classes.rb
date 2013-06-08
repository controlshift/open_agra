class AddOptimisationClasses < ActiveRecord::Migration
  def up

    execute "CREATE EXTENSION IF NOT EXISTS hstore"

    create_table :shares do |t|
      t.string  :code, length: 16
      t.integer :facebook_share_variant_id
      t.integer :petition_id
      t.hstore  :session_store
      t.timestamps
    end

    add_index :shares, :code, :unique => true

    create_table :facebook_share_variants do |t|
      t.string :title
      t.text   :description
      t.string :type

      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at

      t.integer :petition_id

      t.timestamps
    end

    add_index :facebook_share_variants, :petition_id
  end

  def down
    drop_table :shares
    drop_table :facebook_share_variants
  end
end
