class AddUniqueConstraintToGroups < ActiveRecord::Migration
  def change
    remove_index :groups, :slug
    add_index :groups, :slug, unique: true
  end
end
