class AddCommentsToSignatures < ActiveRecord::Migration
  def change
  	add_column :signatures, :comment, :text
  end
end
