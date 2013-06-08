class AddExternalIdToPetition < ActiveRecord::Migration
  def change
    add_column :petitions, :external_id, :string, length: 30
  end
end
