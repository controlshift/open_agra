class CreateTargetCollections < ActiveRecord::Migration
  def change
    create_table :target_collections do |t|
      t.string :name
      t.integer :organisation_id
      t.timestamps
    end


    add_column :targets, :target_collection_id, :integer
    add_column :targets, :geography_id, :integer
    add_column :efforts, :target_collection_id, :integer
    add_index  :targets, :target_collection_id
  end
end
