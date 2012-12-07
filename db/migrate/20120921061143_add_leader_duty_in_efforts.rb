class AddLeaderDutyInEfforts < ActiveRecord::Migration
  def change
      add_column :efforts, :leader_duty, :text
  end
end
