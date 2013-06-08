# == Schema Information
#
# Table name: campaign_admins
#
#  id               :integer         not null, primary key
#  petition_id      :integer
#  user_id          :integer
#  invitation_email :string(255)
#  invitation_token :string(60)
#

class CampaignAdmin < ActiveRecord::Base
  belongs_to :petition, touch: true
  belongs_to :user, touch: true

  validates :user_id, uniqueness: { scope: :petition_id}, if: -> { self.user }
  validates :petition_id, presence: true
  validates :invitation_token, uniqueness: true, length: { maximum: 60 }
  validates :invitation_email, presence: true, uniqueness: { scope: :petition_id, case_sensitive: false}, email_format: true
  validate :user_email, if: -> { self.user }

  attr_accessible :invitation_email, :invitation_token

  strip_attributes only: [:invitation_email]

  include HasToken

  def token_field
    :invitation_token
  end

  def user_email
    errors.add(:user_id, I18n.t('errors.messages.user_email.doesnt_match')) unless self.user.email == self.invitation_email
  end

  def email
    invitation_email
  end
end
