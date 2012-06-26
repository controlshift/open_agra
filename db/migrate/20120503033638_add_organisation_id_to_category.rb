class AddOrganisationIdToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :organisation_id, :integer
    add_index :categories, :organisation_id
  end
end
