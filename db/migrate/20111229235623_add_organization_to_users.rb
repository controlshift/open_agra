class AddOrganizationToUsers < ActiveRecord::Migration
  def change
    add_column :users, :org_admin, :boolean, :default => false
    add_index :users, [:email, :organisation_id]
  end
end
