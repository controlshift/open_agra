class ChangeHelperTextTypeOfEffort < ActiveRecord::Migration
  def up
    change_column :efforts, :title_help, :text
    change_column :efforts, :who_help, :text
    change_column :efforts, :what_help, :text
    change_column :efforts, :why_help, :text
  end

  def down
    change_column :efforts, :title_help, :string
    change_column :efforts, :who_help, :string
    change_column :efforts, :what_help, :string
    change_column :efforts, :why_help, :string
  end
end
