class CreateCampaignAdmins < ActiveRecord::Migration
  def up
    create_table :campaign_admins do |t|
      t.integer :petition_id
      t.integer :user_id
      t.string :invitation_email
      t.string :invitation_token, limit: 60
    end

    add_index :campaign_admins, [:petition_id, :user_id]
    add_index :campaign_admins, [:user_id, :petition_id]
  end

  def down
    drop_table :campaign_admins
  end
end
