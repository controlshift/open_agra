class AddJoinGroupToSignatures < ActiveRecord::Migration
  def change
  	add_column :signatures, :join_group, :boolean
  end
end
