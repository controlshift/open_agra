class SetDefaultCampaignAdmin < ActiveRecord::Migration
  def up
    User.all.each do |user|
      user.petitions.each do |petition|
        if !CampaignAdmin.find_by_petition_id_and_user_id(petition.id, user.id)
          campaign_admin = CampaignAdmin.new(invitation_email: user.email)
          campaign_admin.petition = petition
          campaign_admin.user = user
          campaign_admin.save!
        end
      end
    end
  end

  def down
  end
end
