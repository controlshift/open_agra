class UpdateComments < ActiveRecord::Migration
  def up
    # set a default value for the up_count
    change_column :comments, :up_count, :integer, default: 0

    # replace the index on signature_id with a composite index that should
    # cover queries that are needed on the petition view page.
    remove_index :comments, :signature_id
    add_index :comments, [:signature_id, :flagged_at, :approved, :up_count], name: 'good_comments'

    # drop flagged boolean, we'll just use the presence of flagged_at instead.
    remove_column :comments, :flagged
  end

  def down
    add_column :comments, :flagged, :boolean
    remove_index :comments, name: 'good_comments'
    add_index :comments, :signature_id
    change_column :comments, :up_count, :integer
  end
end
