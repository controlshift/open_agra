class AddSettingsToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :settings, :text
  end
end
