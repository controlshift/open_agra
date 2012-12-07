class AddEffortTypeToEffort < ActiveRecord::Migration
  def change
    add_column :efforts, :effort_type, :string
  end
end
