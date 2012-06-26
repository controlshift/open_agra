class AddExtrasToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :extras, :text
    remove_column :locations, :precision
  end
end
