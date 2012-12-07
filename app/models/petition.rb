# == Schema Information
#
# Table name: petitions
#
#  id                           :integer         not null, primary key
#  title                        :string(255)
#  who                          :string(255)
#  why                          :text
#  what                         :text
#  created_at                   :datetime
#  updated_at                   :datetime
#  user_id                      :integer
#  slug                         :string(255)
#  organisation_id              :integer         not null
#  image_file_name              :string(255)
#  image_content_type           :string(255)
#  image_file_size              :integer
#  image_updated_at             :datetime
#  delivery_details             :text
#  cancelled                    :boolean         default(FALSE), not null
#  token                        :string(255)
#  admin_status                 :string(255)     default("unreviewed")
#  launched                     :boolean         default(FALSE), not null
#  campaigner_contactable       :boolean         default(TRUE)
#  admin_reason                 :text
#  administered_at              :datetime
#  effort_id                    :integer
#  admin_notes                  :text
#  source                       :string(255)
#  group_id                     :integer
#  location_id                  :integer
#  petition_letter_file_name    :string(255)
#  petition_letter_content_type :string(255)
#  petition_letter_file_size    :integer
#  petition_letter_updated_at   :datetime
#  alias                        :string(255)
#  achievements                 :text
#  bsd_constituent_group_id     :string(255)
#  target_id                    :integer
#

class Petition < ActiveRecord::Base
  extend Forwardable
  extend EfficientCounts
  include HasSlug
  include Progress
  SHARE_ACHIEVEMENTS = [:share_on_facebook, :share_with_friends_on_facebook, :share_on_twitter, :share_via_email]
  ACHIEVEMENTS = SHARE_ACHIEVEMENTS + [:leading_progress]
  store :achievements, accessors: ACHIEVEMENTS

  EDIT_STATUSES = [:edited, :edited_inappropriate]
  ADMINISTRATIVE_STATUSES = [:unreviewed, :suppressed, :inappropriate, :approved, :good, :awesome]
  MODERATION_STATUSES = EDIT_STATUSES + ADMINISTRATIVE_STATUSES

  APPROPRIATE_STATUSES = [:good, :awesome]
  INAPPROPRIATE_STATUSES = [:inappropriate, :edited_inappropriate]

  validates :title, presence: true, length: { within: 3..100 }, format: { with: /(.*[0-9a-zA-Z].*){3}/, message: "must contain at least 3 letters/numbers" }
  validates :who,   presence: true, length: { maximum: 240 }
  validates :what,  presence: true, length: { maximum: 5000 }
  validates :why,   presence: true, length: { maximum: 5000 }
  validates :delivery_details, length: { maximum: 500 }
  validates :alias, length: { within: 3..255 }, allow_blank: true,
                    format: { with: /\A[0-9a-zA-Z\-]+\z/, message: "can contains only letters/numbers/hyphens" },
                    uniqueness: { scope: :organisation_id, message: 'has already taken', case_sensitive: false }

  validates_inclusion_of :admin_status, in: MODERATION_STATUSES
  validates_presence_of :admin_reason, if: -> { self.admin_status == :inappropriate }

  validates_presence_of  :target, if: -> { (self.effort && self.effort.specific_targets?) }
  validates_presence_of  :effort, if: -> { self.target }

  strip_attributes only: [:title, :who, :what, :why, :delivery_details]
  validates :organisation, presence: true

  belongs_to :user
  belongs_to :organisation
  belongs_to :effort
  belongs_to :target
  belongs_to :group
  belongs_to :location
  has_many :signatures
  has_many :campaign_admins

  def admins
    # collection of campaign_admin users + the petition creator.
    (campaign_admins.collect{|ca| ca.user} << user).uniq.compact
  end

  has_many :flags, class_name: "PetitionFlag"
  has_many :blast_emails, class_name: "PetitionBlastEmail"
  has_many :categorized_petitions
  has_many :categories, through: :categorized_petitions
  accepts_nested_attributes_for :categorized_petitions, reject_if: :all_blank, allow_destroy: true

  liquid_methods :title, :who, :what, :why, :to_param, :organisation
  before_save :update_admin_attributes, :generate_token

  def_delegator :user, :email
  def_delegator :user, :first_name
  def_delegator :user, :last_name

  include HasPaperclipImage
  has_paperclip_image styles: {form: "200x122>", hero: "330x330>", large: "590x525>"}, attr_accessible: true

  include HasPaperclipFile
  has_paperclip_file :petition_letter, attr_accessible: true

  attr_accessible :title, :who, :what, :why, :delivery_details,
                  :campaigner_contactable, :effort_id, :source, :group_id, :categorized_petitions_attributes, :location_id,
                  :share_on_facebook, :share_with_friends_on_facebook, :share_on_twitter, :share_via_email, :target_id

  def admin_status
    value = read_attribute(:admin_status)
    value.nil? ? nil : value.to_sym
  end

  def admin_status= (value)
    write_attribute(:admin_status, value.to_s)
  end

  def prohibited?
    INAPPROPRIATE_STATUSES.include?(admin_status)
  end

  def suppressed?
    admin_status == :suppressed
  end

  def country
    organisation ? organisation.country : nil
  end

  searchable do
    text :title, :who, :what, :why, :delivery_details
    text(:last_name) { user.last_name if user }
    text(:first_name) { user.first_name if user }
    text(:email) { user.email if user }
    text(:categories) do
      categories.map { |category| category.name }
    end

    latlon(:location) { location if location }
    integer(:organisation_id) # for filtering searches
    integer(:effort_id) { effort_id if effort_id }
    integer(:user_id) # for filtering searches
    time :created_at # for sorting
    time :updated_at # for sorting
    time :image_updated_at # for sorting
    integer :category_ids, multiple: true, references: Category
    boolean :launched
    string :admin_status
    string :admin_notes_tags, multiple: true
    text :admin_notes_without_tags
    boolean :cancelled
  end

  def admin_notes_tags
    admin_notes.present? ? admin_notes.scan(/#\w*\b/) : []
  end

  def admin_notes_without_tags
    admin_notes.present? ? admin_notes.split(/#\w*\b/).join('') : ''
  end

  def recent_signatures
    self.signatures.order("created_at DESC").limit(9)
  end


  # TODO: This is disgusting. Rewrite.
  scope :hot, ->(organisations, groups = []) {
    select_stmt = <<SQL
petitions.*,
(SELECT count(*) FROM signatures s WHERE s.petition_id = petitions.id) AS total_signatures,
(SELECT count(*) FROM signatures s WHERE s.petition_id = petitions.id AND s.created_at >= NOW() - '1 day'::INTERVAL) AS today_signatures,
(SELECT count(*) FROM signatures s WHERE s.petition_id = petitions.id AND s.created_at >= NOW() - '7 days'::INTERVAL)/7 AS week_signatures,
(CASE
  WHEN (SELECT count(*) FROM signatures s WHERE s.petition_id = petitions.id AND s.created_at >= NOW() - '1 day'::INTERVAL) < (SELECT count(*) FROM signatures s WHERE s.petition_id = petitions.id AND s.created_at >= NOW() - '7 days'::INTERVAL)/7
  THEN (SELECT count(*) FROM signatures s WHERE s.petition_id = petitions.id AND s.created_at >= NOW() - '7 days'::INTERVAL)/7
  ELSE (SELECT count(*) FROM signatures s WHERE s.petition_id = petitions.id AND s.created_at >= NOW() - '1 day'::INTERVAL)
  END)
AS hotness
SQL
    where_stmt = <<SQL
petitions.id IN(
  SELECT petition_id
  FROM signatures
  WHERE petition_id IN (SELECT id FROM petitions WHERE organisation_id in (?)
SQL

    unless groups.empty?
    where_stmt << <<SQL
  AND group_id IN (?)
SQL
    end

    where_stmt << <<SQL
  AND launched = 't')
  AND created_at >= NOW() - '7 days'::INTERVAL
  GROUP BY petition_id
  ORDER BY COUNT(petition_id) DESC
  LIMIT 25
)
SQL
    if groups.empty?
      select(select_stmt).where(where_stmt, organisations.map{|o| o.id}).order('hotness DESC')
    else
      select(select_stmt).where(where_stmt, organisations.map{|o| o.id}, groups.map { |g| g.id }).order('hotness DESC')
    end
  }

  scope :not_orphan, where("petitions.user_id IS NOT NULL")

  scope :launched, where(launched: true)

  scope :one_signature, launched
    .where(Petition.arel_table[:admin_status].not_in INAPPROPRIATE_STATUSES)
    .where(cancelled: false).where(id: Signature.select("petition_id")
    .group(:petition_id)
    .having("count(*) = 1"))

  scope :awesome, launched.where(admin_status: :awesome, cancelled: false).order("updated_at DESC")

  scope :appropriate, launched.where(admin_status: APPROPRIATE_STATUSES, cancelled: false).order("updated_at DESC")

  scope :awaiting_moderation, lambda { |organisation_id|
    launched.where(admin_status: [:unreviewed, :edited, :edited_inappropriate], organisation_id: organisation_id).order("updated_at DESC")
  }

  def flags_count
    @flags_count ||= self.flags.created_after(self.administered_at).count
  end

  def signatures_count_key
    "#{id}_signatures_count"
  end

  def signatures_size
    signatures.size
  end

  def subscribed_signatures
    signatures.subscribed
  end

  def self.create_with_param(attrs)
    effort = attrs[:effort]
    target = attrs[:target]
    petition = Petition.new title: "#{effort.title_default}: #{target.name}", who: target.name,
                            what: effort.what_default, why: effort.why_default, image: effort.default_petition_image
    petition.organisation = effort.organisation
    petition.location = target.location
    petition.categories << effort.categories
    petition.target = target
    petition.effort = effort
    petition
  end

  def schedule_reminder_email!
    Jobs::PromotePetitionJob.new.promote(self, :reminder_when_dormant)
  end

  def achieve_leading_progress!
    self.achievements[:leading_progress] = "lead"
  end

  def achieve_training_progress!
    self.achievements[:leading_progress] = "training"
  end

  def progress
    return "share" if shared?
    return "manage" if managed?
    achievements[:leading_progress]
  end

  private

  def shared?
    SHARE_ACHIEVEMENTS.all? do |i|
      self.achievements[i] == "1"
    end
  end

  def managed?
    SHARE_ACHIEVEMENTS.any? do |i|
      self.achievements[i] == "1"
    end
  end

  def new_petition_title_of(target)
    "#{title_default}: #{target.name}"
  end

  def update_admin_attributes
    set_admin_status
    set_administered_at
  end

  def set_admin_status
    if persisted? && (title_changed? || who_changed? || what_changed? || why_changed? || delivery_details_changed? || image_updated_at_changed?) && admin_status != :unreviewed
      self.admin_status = self.prohibited? ? :edited_inappropriate : :edited
    end
  end

  def set_administered_at
    self.administered_at = Time.now if requires_administered_at?
  end

  def requires_administered_at?
    ADMINISTRATIVE_STATUSES.include?(admin_status) && admin_status != :unreviewed
  end

  def generate_token
    self.token = Digest::SHA1.hexdigest("#{slug}#{Agra::Application.config.sha1_salt}")
  end
end
