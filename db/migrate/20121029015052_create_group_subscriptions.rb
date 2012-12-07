class CreateGroupSubscriptions < ActiveRecord::Migration
  def up
    create_table :group_subscriptions do |t|
      t.integer  :group_id
      t.integer  :member_id
      t.datetime :unsubscribed_at
      t.string   :token

      t.timestamps
    end

    add_index :group_subscriptions, [:member_id, :group_id], unique: true
    add_index :group_subscriptions, [:group_id, :unsubscribed_at]
    add_index :group_subscriptions, :token

    #Signature.subscribed.find_each do | signature |
    #  group = signature.petition.group
    #  if group.present?
    #    GroupSubscription.find_or_create!(signature.member, group)
    #  end
    #end
  end

  def down
    drop_table :group_subscriptions
  end
end
