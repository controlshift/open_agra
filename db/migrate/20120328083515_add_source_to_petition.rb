class AddSourceToPetition < ActiveRecord::Migration
  def change
    add_column :petitions, :source, :string
  end
end
