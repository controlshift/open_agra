# == Schema Information
#
# Table name: group_members
#
#  id               :integer         not null, primary key
#  group_id         :integer
#  user_id          :integer
#  invitation_email :string(255)
#  invitation_token :string(60)
#

class GroupMember < ActiveRecord::Base
  belongs_to :group, touch: true
  belongs_to :user, touch: true

  validates :user_id, uniqueness: { scope: :group_id}, if: -> { self.user }
  validates :group_id, presence: true
  validates :invitation_token, uniqueness: true, length: { maximum: 60 }
  validates :invitation_email, presence: true, uniqueness: { scope: :group_id, case_sensitive: false}, email_format: true
  validate :user_email, if: -> { self.user }

  attr_accessible :invitation_email, :invitation_token
  
  strip_attributes only: [:invitation_email]

  include HasToken

  def token_field
    :invitation_token
  end

  def user_email
    errors.add(:user_id, 'User does not have the same email as the invitation.') unless self.user.email.downcase == self.invitation_email.downcase
  end

end
