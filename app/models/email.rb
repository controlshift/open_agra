# == Schema Information
#
# Table name: emails
#
#  id           :integer         not null, primary key
#  to_address   :string(255)     not null
#  from_name    :string(255)     not null
#  from_address :string(255)     not null
#  subject      :string(255)     not null
#  content      :text            not null
#  created_at   :datetime
#  updated_at   :datetime
#

class Email < ActiveRecord::Base
  validates :to_address, presence: true, format: { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }
  validates :from_name, presence: true, length: { maximum: 100 }, format: { :with => /\A([\p{Word} \.'\-]+)\Z/u }
  validates :from_address, presence: true, format: { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }

  validates :subject, presence: true, length: { maximum: 255 }
  validates :content, presence: true, length: { maximum: 1000 }

  attr_accessible :to_address, :from_name, :from_address, :subject, :content
  
  def email_with_name
    "\"#{from_name}\" <#{from_address}>"
  end
end
