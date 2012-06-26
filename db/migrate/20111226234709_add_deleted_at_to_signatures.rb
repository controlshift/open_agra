class AddDeletedAtToSignatures < ActiveRecord::Migration
  def change
    add_column :signatures, :deleted_at, :datetime
  end
end
