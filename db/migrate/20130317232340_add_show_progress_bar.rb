class AddShowProgressBar < ActiveRecord::Migration
  def up
    add_column :petitions, :show_progress_bar, :boolean, default: true
  end

  def down
    remove_column :petitions, :show_progress_bar
  end
end
