class AddLaunchedToPetitions < ActiveRecord::Migration
  def change
    add_column :petitions, 'launched', :boolean, default: false, null: false
  end
end
