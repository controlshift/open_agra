class AddSlugColumnToPeition < ActiveRecord::Migration
  def change
    add_column :petitions, :slug, :string
  end
end
