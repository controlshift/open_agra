class RenameLeaderDutyOfEffortTable < ActiveRecord::Migration
  def change
    rename_column :efforts, :leader_duty, :leader_duties_text
  end
end
