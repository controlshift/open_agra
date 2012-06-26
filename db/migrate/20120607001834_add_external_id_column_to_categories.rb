class AddExternalIdColumnToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :external_id, :string
    remove_column :categories, :external_ids
  end
end
