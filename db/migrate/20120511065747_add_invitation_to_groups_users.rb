class AddInvitationToGroupsUsers < ActiveRecord::Migration
  def up
    change_table :groups_users do |t|
      t.string :invitation_email
      t.string :invitation_token, limit: 60
      t.datetime :invitation_sent_at
      t.datetime :invitation_accepted_at
    end
  end

  def down
    remove_column :groups_users, :invitation_email
    remove_column :groups_users, :invitation_token
    remove_column :groups_users, :invitation_accepted_at
    remove_column :groups_users, :invitation_sent_at
  end
end
