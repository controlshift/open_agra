# == Schema Information
#
# Table name: group_subscriptions
#
#  id              :integer         not null, primary key
#  group_id        :integer
#  member_id       :integer
#  unsubscribed_at :datetime
#  token           :string(255)
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#

class GroupSubscription < ActiveRecord::Base
  belongs_to :member
  belongs_to :group

  validates :member_id, presence: true, uniqueness: {:scope => :group_id}
  validates :group_id,  presence: true
  scope :subscribed, where(unsubscribed_at: nil)


  after_create :create_token!


  def self.subscribe!(member, group)
    subscription = find_or_create!(member, group)
    if subscription.unsubscribed?
      subscription.resubscribe!
    end
    subscription
  end

  def unsubscribe!
    update_attribute(:unsubscribed_at, Time.now)
  end

  def resubscribe!
    update_attribute(:unsubscribed_at, nil)
  end

  def unsubscribed?
    unsubscribed_at != nil
  end


  def to_param
    token
  end

  def email
    member.email
  end

  private

  def self.find_or_create!(member, group)
    subscription = GroupSubscription.where(member_id: member.id, group_id: group.id).first
    if subscription.nil?
      subscription = GroupSubscription.create(member: member, group: group)
    end
    subscription
  end

  def create_token!
    update_attribute(:token, Digest::SHA1.hexdigest("#{id}#{Agra::Application.config.sha1_salt}"))
  end


end
