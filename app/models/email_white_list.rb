# == Schema Information
#
# Table name: email_white_lists
#
#  id         :integer         not null, primary key
#  email      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class EmailWhiteList < ActiveRecord::Base
  validates :email, presence: true, uniqueness: {case_sensitive: false}, email_format: true

  attr_accessible :email
  strip_attributes only: [:email]

  def self.find_by_email(email)
    EmailWhiteList.where("LOWER(email) = ?", email.to_s.strip.downcase).first
  end
end
