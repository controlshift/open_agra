class AddExternalMailingIdToSignature < ActiveRecord::Migration
  def change
    add_column :signatures, :akid, :string
  end
end
