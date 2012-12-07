# == Schema Information
#
# Table name: petition_flags
#
#  id          :integer         not null, primary key
#  petition_id :integer
#  user_id     :integer
#  ip_address  :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  reason      :text
#

class PetitionFlag < ActiveRecord::Base
  validates :petition_id, presence: true
  validates :reason, presence: true
  validates :user_id, uniqueness: {scope: :petition_id, message: 'You have already flagged this petition'},
            allow_blank: true
  validates :ip_address, uniqueness: {scope: [:user_id, :petition_id], message: 'You have already flagged this petition'},
            presence: true, format: {with: /^([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])$/}

  belongs_to :petition
  belongs_to :user

  scope :created_after, ->(time){ time.nil? ? where("created_at > ?", 1.year.ago) : where("created_at > ?", time) }

end
