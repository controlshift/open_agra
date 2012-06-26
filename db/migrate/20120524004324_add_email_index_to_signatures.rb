class AddEmailIndexToSignatures < ActiveRecord::Migration
  def change
    add_index :signatures, [:email, :petition_id, :deleted_at], :unique => true
  end
end
