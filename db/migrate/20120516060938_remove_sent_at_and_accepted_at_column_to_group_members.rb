class RemoveSentAtAndAcceptedAtColumnToGroupMembers < ActiveRecord::Migration
  def change
    remove_column :group_members, :invitation_accepted_at
    remove_column :group_members, :invitation_sent_at
  end
end
