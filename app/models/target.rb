# == Schema Information
#
# Table name: targets
#
#  id              :integer         not null, primary key
#  name            :string(255)
#  phone_number    :string(255)
#  email           :string(255)
#  location_id     :integer
#  organisation_id :integer
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#  slug            :string(255)
#

class Target < ActiveRecord::Base
  include HasSlug

  belongs_to :location
  belongs_to :geography
  belongs_to :organisation
  belongs_to :target_collection

  has_many :petitions
  attr_accessible :email, :name, :phone_number, :location_id
  validates :name, presence: true, uniqueness: {message: I18n.t('errors.messages.taken'), scope: :organisation_id}
  validates :phone_number, length: {maximum: 50}, format: {with: /\A[0-9 \-\.\+\(\)]*\Z/}, allow_blank: true
  validates :email, email_format: true, allow_blank: true
  validates :organisation, presence: true

  validate :location_xor_geography

  def self.autocomplete(string, organisation)
    if string.length > 2
      names = organisation.targets.where("lower(name) LIKE lower(?)", "#{string}%").limit(10).select('name').order('length(name) ASC')
      names.map(&:name)
    else
      []
    end
  end

  def location_xor_geography
    if !(location.blank? ^ geography.blank?)
      self.errors[:base] << I18n.t('errors.messages.target.either_location_or_geo')
    end
  end
end
