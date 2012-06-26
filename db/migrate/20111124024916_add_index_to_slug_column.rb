class AddIndexToSlugColumn < ActiveRecord::Migration
  def change
    add_index :petitions, :slug
  end
end
