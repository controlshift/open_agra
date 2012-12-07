class CreateTargets < ActiveRecord::Migration
  def change
    create_table :targets do |t|
      t.string :name
      t.string :phone_number
      t.string :email
      t.references :location
      t.references :organisation

      t.timestamps
    end
    add_index :targets, :location_id
    add_index :targets, :organisation_id
  end
end
