class AddSlugToTarget < ActiveRecord::Migration
  def change
    add_column :targets, :slug, :string
  end
end
