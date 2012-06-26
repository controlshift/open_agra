# == Schema Information
#
# Table name: users
#
#  id                     :integer         not null, primary key
#  email                  :string(255)     default(""), not null
#  encrypted_password     :string(128)     default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer         default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime        not null
#  updated_at             :datetime        not null
#  first_name             :string(255)
#  last_name              :string(255)
#  admin                  :boolean
#  phone_number           :string(255)
#  postcode               :string(255)
#  join_organisation      :boolean
#  organisation_id        :integer         not null
#  org_admin              :boolean         default(FALSE)
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  opt_out_site_email     :boolean
#  facebook_id            :string(255)
#

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :confirmable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, :last_name,
                  :phone_number, :postcode, :join_organisation, :agree_toc, :opt_out_site_email

  validates :agree_toc, acceptance: true, allow_nil: false, on: :create
  validates :first_name, :last_name, presence: true, length: {maximum: 50},
            format: {with: /\A([\p{Word} \.'\-]+)\Z/u}
  validates :email, presence: true, uniqueness: {scope: 'organisation_id', case_sensitive: false}, email_format: true
  validates :phone_number, presence: true, length: {maximum: 50},
            format: {with: /\A[0-9 \-\.\+\(\)]*\Z/}
  validates :postcode, presence: true, length: {maximum: 20}
  validates :password, presence: true, length: {within: 6..128}, confirmation: true, allow_blank: true,
            if: :password_required?

  strip_attributes only: [:email, :first_name, :last_name, :phone_number, :postcode]

  liquid_methods :first_name, :full_name

  def self.extract_accessible_attributes_symbol_hash_values(attributes)
    attributes.symbolize_keys.slice(:email, :password, :password_confirmation, :remember_me, :first_name, :last_name,
                                    :phone_number, :postcode, :join_organisation, :agree_toc)
  end

  def accessible_attributes_hash_values
    User.extract_accessible_attributes_symbol_hash_values(attributes)
  end

  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end

  belongs_to :organisation
  has_many :petition_flags
  has_many :petitions

  def manageable_petitions
    # collection of campaign_admin petitions + the petitions this user owns
    (campaign_admins.collect{|ca| ca.petition} << petitions).flatten.uniq
  end

  has_many :campaign_admins
  has_many :groups, through: :group_members
  has_many :group_members

  after_save :update_related_petitions

  def full_name
    "#{first_name} #{last_name}"
  end

  protected
  
  def confirmation_required?
    false
  end

  def self.find_for_database_authentication(conditions)
    conditions = conditions.dup
    organisation_id = conditions.delete(:organisation_id)
    email = conditions.delete(:email)
    where(conditions).where(["lower(email) = :value", {value: email.downcase}]).where({organisation_id: organisation_id}).first
  end

  def self.find_by_email(email)
    where("lower(email) = ?", email.to_s.strip.downcase).first
  end

  def self.find_by_email_and_organisation_id(email, organisation_id)
    where("lower(email) = ? AND organisation_id = ?", email.to_s.strip.downcase, organisation_id).first
  end

  def update_related_petitions
    if first_name_changed? || last_name_changed? || email_changed?
      petitions.each do |p|
        p.solr_index
      end
    end
  end
end
