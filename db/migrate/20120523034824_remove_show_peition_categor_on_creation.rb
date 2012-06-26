class RemoveShowPeitionCategorOnCreation < ActiveRecord::Migration
  def up
    remove_column :organisations, :show_petition_category_on_creation
  end

  def down
    add_column :organisations, :show_petition_category_on_creation, :boolean
  end
end
