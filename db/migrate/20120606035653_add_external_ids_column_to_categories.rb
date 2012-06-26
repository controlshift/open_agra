class AddExternalIdsColumnToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :external_ids, :text
    remove_column :categories, :bsd_cons_group_id
  end
end
