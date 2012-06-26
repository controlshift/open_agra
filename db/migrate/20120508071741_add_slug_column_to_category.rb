class AddSlugColumnToCategory < ActiveRecord::Migration
  def up
    add_column :categories, :slug, :string
    add_index :categories, :slug
    Category.all.each { |c| c.save }
  end

  def down
    remove_column :categories, :slug
  end
end
