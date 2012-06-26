class AddBsdConsGroupIdColumnToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :bsd_cons_group_id, :string
  end
end
