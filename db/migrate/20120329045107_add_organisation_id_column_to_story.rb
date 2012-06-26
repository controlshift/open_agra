class AddOrganisationIdColumnToStory < ActiveRecord::Migration
  def change
    add_column :stories, :organisation_id, :integer
    add_index :stories, :organisation_id
  end
end
