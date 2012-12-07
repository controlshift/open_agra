# == Schema Information
#
# Table name: signatures
#
#  id                       :integer         not null, primary key
#  petition_id              :integer
#  email                    :string(255)     not null
#  first_name               :string(255)
#  last_name                :string(255)
#  phone_number             :string(255)
#  postcode                 :string(255)
#  created_at               :datetime
#  join_organisation        :boolean
#  deleted_at               :datetime
#  token                    :string(255)
#  unsubscribe_at           :datetime
#  external_constituent_id  :string(255)
#  member_id                :integer
#  additional_fields        :hstore
#  cached_organisation_slug :string(255)
#

class Signature < ActiveRecord::Base
  include HasMember
  include Extensions::AdditionalFields

  default_scope conditions: {deleted_at: nil}

  validates :email, presence: true, uniqueness: {scope: :petition_id, message: 'has already signed',
                                                 case_sensitive: false}, email_format: true
  validates :postcode, postal_code: true, on: :create
  validates :postcode, presence: true, if: Proc.new { |s| s.country != 'IN' }

  validates :first_name, :last_name, presence: true, length: {maximum: 50}, format: {with: /\A([\p{Word} \.'\-]+)\Z/u}
  validates :phone_number, length: {maximum: 50}, format: {with: /\A[0-9 \-\.\+\(\)]*\Z/}, allow_blank: true
  validates :petition_id, presence: true

  attr_accessible :email, :postcode, :first_name, :last_name, :phone_number, :join_organisation
  strip_attributes only: [:email, :first_name, :last_name, :phone_number, :postcode]

  belongs_to :petition
  belongs_to :member


  scope :subscribed, where(unsubscribe_at: nil, join_organisation: true)
  scope :since, ->(time){ time.nil? ? all : where("created_at > ?", time) }

  after_create :create_token!
  before_save  :ensure_organisation_slug

  liquid_methods :first_name, :last_name, :email, :postcode, :to_param, :petition

  def self.lookup(email, petition)
    where("LOWER(email) = ? AND petition_id = ?", email.downcase, petition.id).first
  end

  def first_name_or_friend
    first_name.blank? ? "Friend" : first_name
  end

  def full_name_with_mask
    full_name true
  end

  def country
    petition ? petition.country : nil
  end

  def full_name(masked = false)
    if first_name.present? && last_name.present?
      masked ? "#{first_name} #{last_name[0]}." : "#{first_name} #{last_name}"
    elsif first_name.present?
      first_name
    elsif last_name.present?
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
  
  def to_hash
    {
      first_name: self.first_name,
      last_name: self.last_name,
      email: self.email, 
      phone_number: self.phone_number,
      postcode: self.postcode,
      join_organisation: self.join_organisation, 
      errors: self.errors
    }
  end

  def organisation
    petition.organisation
  end

  def facebook_id
    nil
  end

  private

  def ensure_organisation_slug
    if cached_organisation_slug.blank? && petition && petition.organisation
      self.cached_organisation_slug = petition.organisation.slug
    end
  end


  def create_token!
    update_attribute(:token, Digest::SHA1.hexdigest("#{id}#{Agra::Application.config.sha1_salt}"))
  end

end
