class DeleteCommentFromSignatures < ActiveRecord::Migration
  def up
  	remove_column :signatures, :comment
  end

  def down
  	add_column :signatures, :comment, :text
  end
end
