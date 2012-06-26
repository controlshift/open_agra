class AddUnsubscribeAtToSignatures < ActiveRecord::Migration
  def change
    add_column :signatures, :unsubscribe_at, :datetime
  end
end
