class RemoveCampaignAdmins < ActiveRecord::Migration
  def up
    CampaignAdmin.delete_all
  end

  def down
  end
end
