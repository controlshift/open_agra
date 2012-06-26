class CreateContents < ActiveRecord::Migration
  def change
    create_table :contents do |t|
      t.integer :organisation_id
      t.string :slug
      t.string :name
      t.string :category
      t.text :body
      t.string :filter, :default => 'none'
      t.timestamps
    end

    add_index :contents, [:slug, :organisation_id], :unique => true
    add_index :contents, :category
  end


end
