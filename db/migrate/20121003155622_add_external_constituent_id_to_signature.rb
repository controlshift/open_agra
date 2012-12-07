class AddExternalConstituentIdToSignature < ActiveRecord::Migration
  def change
    add_column :signatures, :external_constituent_id, :string
    add_column :users, :external_constituent_id, :string
  end
end
