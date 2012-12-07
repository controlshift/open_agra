class AddDistanceLimitToEfforts < ActiveRecord::Migration
  def change
    add_column :efforts, :distance_limit, :integer, default: 100
  end
end
