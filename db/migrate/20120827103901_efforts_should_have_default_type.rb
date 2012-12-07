class EffortsShouldHaveDefaultType < ActiveRecord::Migration
  def up
    change_column :efforts, :effort_type, :string, default: 'open_ended'
    execute "UPDATE efforts SET effort_type='open_ended' WHERE effort_type IS NULL"
  end

  def down
    change_column :efforts, :effort_type, :string
  end
end
