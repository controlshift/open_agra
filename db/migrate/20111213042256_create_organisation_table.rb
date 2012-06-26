class CreateOrganisationTable < ActiveRecord::Migration
  def up
    create_table :organisations do |t|
      t.string :name
      t.timestamps
    end

    change_table :users do |t|
      t.references :organisation, null: false
      t.foreign_key :organisations
    end

    change_table :petitions do |t|
      t.references :organisation, null: false
      t.foreign_key :organisations
    end
  end

  def down
    change_table :users do |t|
      t.remove_foreign_key :organisations
      t.remove :organisation_id
    end

    change_table :petitions do |t|
      t.remove_foreign_key :organisations
      t.remove :organisation_id
    end

    drop_table :organisations
  end
end
