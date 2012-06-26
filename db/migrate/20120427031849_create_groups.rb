class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.references :organisation
      t.string :title
      t.string :slug
      t.text :description

      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at
      t.timestamps
    end

    add_column :petitions, :group_id, :integer

    add_index :petitions, :group_id
    add_index :groups, :organisation_id
    add_index :groups, :slug

    create_table :groups_users do |t|
      t.references :group
      t.references :user
    end

    add_index :groups_users, [:group_id, :user_id]
    add_index :groups_users, [:user_id, :group_id]

  end
end
