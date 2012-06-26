class ChangeDefaultUseWhiteListToFalse < ActiveRecord::Migration
  def up
    change_column_default(:organisations, :use_white_list, false)
  end

  def down
    change_column_default(:organisations, :use_white_list, true)
  end
end
