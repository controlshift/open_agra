class RenameTableGroupsUsersToGroupMembers < ActiveRecord::Migration
  def up
    rename_table :groups_users, :group_members
  end

  def down
    rename_table :group_members, :groups_users
  end
end
