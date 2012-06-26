class AddParentNameToOrganisation < ActiveRecord::Migration
  def change
    add_column :organisations, :parent_name, :string
  end
end
