class UseWhiteListBoolean < ActiveRecord::Migration
  def up
    add_column :organisations, :use_white_list, :boolean, :default => true
  end

  def down
    remove_column :organisations, :use_white_list
  end
end
