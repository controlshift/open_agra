# == Schema Information
#
# Table name: signatures
#
#  id                :integer         not null, primary key
#  petition_id       :integer
#  email             :string(255)     not null
#  first_name        :string(255)
#  last_name         :string(255)
#  phone_number      :string(255)
#  postcode          :string(255)
#  created_at        :datetime
#  join_organisation :boolean
#  deleted_at        :datetime
#  token             :string(255)
#  unsubscribe_at    :datetime
#

class Signature < ActiveRecord::Base
  default_scope conditions: {deleted_at: nil}

  validates :email, presence: true, uniqueness: {scope: :petition_id, message: 'has already signed',
                                                 case_sensitive: false}, email_format: true
  validates :postcode, presence: true

  validates :first_name, :last_name, presence: true, length: {maximum: 50}, format: {with: /\A([\p{Word} \.'\-]+)\Z/u}
  validates :phone_number, length: {maximum: 50}, format: {with: /\A[0-9 \-\.\+\(\)]*\Z/}, allow_blank: true
  validates :petition_id, presence: true

  attr_accessible :email, :postcode, :first_name, :last_name, :phone_number, :join_organisation
  strip_attributes only: [:email, :first_name, :last_name, :phone_number, :postcode]

  belongs_to :petition

  scope :subscribed, where(unsubscribe_at: nil, join_organisation: true)
  scope :since, ->(time){ time.nil? ? all : where("created_at > ?", time) }

  after_create :create_token!

  liquid_methods :first_name, :last_name, :email, :postcode, :to_param, :petition

  def first_name_or_friend
    first_name.blank? ? "Friend" : first_name
  end

  def full_name_with_mask
    full_name true
  end
  
  def full_name(masked = false)
    if !first_name.blank? && !last_name.blank?
      masked ? "#{first_name} #{last_name[0]}." : "#{first_name} #{last_name}"
    elsif !first_name.blank?
      first_name
    elsif !last_name.blank?
      last_name
    else
      "Not provided"
    end
  end

  def created_at_iso_8601
    created_at.strftime("%Y-%m-%dT%H:%M:%SZ")
  end

  def to_param
    token
  end

  private

  def create_token!
    update_attribute(:token, Digest::SHA1.hexdigest("#{id}#{Agra::Application.config.sha1_salt}"))
  end

end
