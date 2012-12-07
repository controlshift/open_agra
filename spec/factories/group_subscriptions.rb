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

# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :group_subscription do
  end
end
