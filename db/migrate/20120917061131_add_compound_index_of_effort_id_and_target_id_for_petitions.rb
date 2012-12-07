class AddCompoundIndexOfEffortIdAndTargetIdForPetitions < ActiveRecord::Migration
  def change
    add_index :petitions, [:effort_id, :target_id], name: 'by_effort_id_and_target_id'
  end
end
