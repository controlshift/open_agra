class AddTargetReferenceToPetitions < ActiveRecord::Migration
  def change
    add_column :petitions, :target_id, :integer
  end
end
