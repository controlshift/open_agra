# == Schema Information
#
# Table name: members
#
#  id              :integer         not null, primary key
#  email           :string(255)
#  organisation_id :integer
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#  external_id     :string(255)
#

class Member < ActiveRecord::Base
  has_many :signatures
  has_many :group_subscriptions
  has_one  :user
  belongs_to :organisation

  validates :email, presence: true, uniqueness: {scope: :organisation_id, case_sensitive: false}, email_format: true
  validates :organisation, presence: true
  strip_attributes only: [:email]

  def self.lookup(email, organisation)
    where("LOWER(email) = ? AND organisation_id = ?", email.downcase, organisation.id).first
  end

  def info
    if user
      user
    else
      signatures.last
    end
  end
end
