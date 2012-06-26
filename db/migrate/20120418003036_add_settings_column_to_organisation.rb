class AddSettingsColumnToOrganisation < ActiveRecord::Migration
  def change
    add_column :organisations, :settings, :text
  end
end
