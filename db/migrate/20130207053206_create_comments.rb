class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.text :text
      t.integer :up_count
      t.boolean :flagged
      t.boolean :approved
      t.datetime :flagged_at
      t.integer :flagged_by_id
      t.integer :signature_id
      t.timestamps
    end

    add_index :comments, :flagged_by_id
    add_index :comments, :signature_id
  end
end
