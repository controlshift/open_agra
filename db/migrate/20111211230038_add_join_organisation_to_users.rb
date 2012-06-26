class AddJoinOrganisationToUsers < ActiveRecord::Migration
  def change
    add_column :users, 'join_organisation', :boolean
  end
end
