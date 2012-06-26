class AddLocationToEfforts < ActiveRecord::Migration
  def change
    add_column :petitions, :location_id, :integer
    add_column :efforts, :ask_for_location, :boolean

    add_index :petitions, :location_id
  end
end
