class AddCancelledToPetitions < ActiveRecord::Migration
  def change
    add_column :petitions, :cancelled, :boolean, default: false, null: false
  end
end
