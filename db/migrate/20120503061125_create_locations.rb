class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string  :query
      t.decimal :latitude,   :precision => 13, :scale => 10
      t.decimal :longitude,  :precision => 13, :scale => 10
      t.string  :street
      t.string  :locality
      t.string  :postal_code
      t.string  :country
      t.string  :precision
      t.string  :region
      t.string  :warning
      t.timestamps
    end
    add_index :locations, :query
    add_index :locations, [:latitude, :longitude]

  end
end
