class AddExternalIdToMember < ActiveRecord::Migration
  def change
    add_column :members, :external_id, :string
    add_column :signatures, :external_id, :string
    add_column :signatures, :new_member, :boolean
  end
end
