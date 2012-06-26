class RenameIndexesForGroupMembersTable < ActiveRecord::Migration
  def up
    remove_index :group_members, name: "index_groups_users_on_group_id_and_user_id"
    remove_index :group_members, name: "index_groups_users_on_user_id_and_group_id"
    add_index :group_members, [:group_id, :user_id], name: "index_group_members_on_group_id_and_user_id"
    add_index :group_members, [:user_id, :group_id], name: "index_group_members_on_user_id_and_group_id"
  end

  def down
    remove_index :group_members, name: "index_group_members_on_group_id_and_user_id"
    remove_index :group_members, name: "index_group_members_on_user_id_and_group_id"
    add_index :group_members, [:group_id, :user_id], name: "index_groups_users_on_group_id_and_user_id"
    add_index :group_members, [:user_id, :group_id], name: "index_groups_users_on_user_id_and_group_id"
  end
end
