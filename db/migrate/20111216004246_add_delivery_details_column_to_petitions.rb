class AddDeliveryDetailsColumnToPetitions < ActiveRecord::Migration
  def change
    add_column :petitions, :delivery_details, :text
  end
end
