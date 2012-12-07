class AddIndexToNameColumnForTargets < ActiveRecord::Migration
  def change
    add_index :targets, :name, name: 'target_name'
  end
end
