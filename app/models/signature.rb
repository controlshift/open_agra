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
#  source                   :string(255)     default("")
#  join_group               :boolean
#  external_id              :string(255)
#  new_member               :boolean
#

require 'shorten_attributes'

class Signature < ActiveRecord::Base
  include HasMember
  include Extensions::AdditionalFields
  include Extensions::Signature::Extension
  include FullName

  default_scope conditions: {deleted_at: nil}

  validates :email, presence: true, uniqueness: {scope: :petition_id, message: I18n.t('errors.messages.signature.already_signed'),
                                                 case_sensitive: false}, email_format: true, length: {maximum: 254}
  validates :postcode, postal_code: true, length: {maximum: 15}, on: :create
  validates :postcode, presence: true, if: Proc.new { |s| s.country != 'IN' }

  validates :first_name, :last_name, presence: true, length: {maximum: 50}, format: {with: /\A([\p{Word} \.'\-]+)\Z/u}
  validates :phone_number, length: {maximum: 30, minimum: 4}, format: {with: /\d/}, allow_blank: true  #just validate that there is a digit
  validates :petition_id, presence: true

  attr_accessible :email, :postcode, :first_name, :last_name, :phone_number, :join_organisation, :join_group, :source, :akid
  strip_attributes   only: [:email, :first_name, :last_name, :phone_number, :postcode]
  shorten_attributes only: [:akid, :source]

  belongs_to :petition
  belongs_to :member
  has_one :comment

  scope :subscribed, where(unsubscribe_at: nil, join_organisation: true)
  scope :since, ->(time){ time.nil? ? all : where("created_at > ?", time) }

  after_create :create_token!
  before_save  :ensure_organisation_slug

  liquid_methods :first_name, :last_name, :email, :postcode, :to_param, :petition

  def self.lookup(email, petition)
    where("LOWER(email) = ? AND petition_id = ?", email.downcase, petition.id).first
  end

  def subscribed?
    unsubscribe_at.blank? && join_organisation?
  end

  def country
    petition ? petition.country : nil
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
      join_group: self.join_group,
      errors: self.errors
    }
  end

  def organisation
    petition.organisation
  end

  def facebook_id
    nil
  end
  
  def fields
    [:first_name, :last_name, :email, :phone_number, :postcode, :join_organisation]
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
