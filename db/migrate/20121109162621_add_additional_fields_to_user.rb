class AddAdditionalFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :additional_fields, :hstore
  end
end
