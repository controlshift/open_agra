class AddAliasColumnToPetition < ActiveRecord::Migration
  def change
    add_column :petitions, :alias, :string
  end
end
