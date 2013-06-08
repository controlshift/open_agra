class Geography < ActiveRecord::Migration
  def up
    execute "CREATE EXTENSION IF NOT EXISTS postgis"

    create_table :geographic_collections do |t|
      t.string :name
    end
    add_index :geographic_collections, :name, unique:true


    create_table :geographies do |t|
      t.integer  :geographic_collection_id
      t.string   :name
      t.geometry :shape, :geographic => true, :has_z => true, :srid => 4326
      t.hstore   :metadata
    end
    add_index :geographies, :shape, :spatial => true


    add_column :locations, :point, :point, :srid => 4326
    add_index  :locations, :point, :spatial => true
  end

  def down
    drop_table :geographies
    remove_column :locations, :point
    execute "DROP EXTENSION IF EXISTS postgis"
  end
end
