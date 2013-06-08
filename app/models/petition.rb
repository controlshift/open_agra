# == Schema Information
#
# Table name: petitions
#
#  id                           :integer         not null, primary key
#  title                        :string(255)
#  who                          :string(255)
#  why                          :text
#  what                         :text
#  created_at                   :datetime        not null
#  updated_at                   :datetime        not null
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
#  external_id                  :string(255)
#  redirect_to                  :text
#  external_facebook_page       :string(255)
#  external_site                :string(255)
#  show_progress_bar            :boolean         default(TRUE)
#  comments_updated_at          :datetime
#

class Petition < ActiveRecord::Base
  extend Forwardable
  extend EfficientCounts
  include HasSlug
  include Progress
  include Shareable

  SHARE_ACHIEVEMENTS = [:share_on_facebook, :share_with_friends_on_facebook, :share_on_twitter, :share_via_email]
  ACHIEVEMENTS = SHARE_ACHIEVEMENTS + [:leading_progress]
  store :achievements, accessors: ACHIEVEMENTS

  EDIT_STATUSES = [:edited, :edited_inappropriate]
  ADMINISTRATIVE_STATUSES = [:unreviewed, :suppressed, :inappropriate, :approved, :good, :awesome]
  MODERATION_STATUSES = EDIT_STATUSES + ADMINISTRATIVE_STATUSES

  APPROPRIATE_STATUSES = [:good, :awesome]
  INAPPROPRIATE_STATUSES = [:inappropriate, :edited_inappropriate]

  validates :title, presence: true, length: { within: 3..100 }, format: { with: /(.*[0-9a-zA-Z].*){3}/, message: I18n.t('errors.messages.title.format') }
  validates :who,   presence: true, length: { maximum: 240 }
  validates :what,  presence: true, length: { maximum: 5000 }
  validates :why,   presence: true, length: { maximum: 5000 }
  validates :delivery_details, length: { maximum: 500 }
  validates :alias, length: { within: 3..255 }, allow_blank: true,
                    format: { with: /\A[0-9a-zA-Z\-]+\z/, message: I18n.t('errors.messages.alias.format') },
                    uniqueness: { scope: :organisation_id, message: I18n.t('errors.messages.taken') , case_sensitive: false }

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
  has_many :comments, through: :signatures, order: 'comments.created_at DESC'
  has_many :campaign_admins
  has_many :facebook_share_variants

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
  before_create :set_comments_updated_at_to_now

  def_delegator :user, :email
  def_delegator :user, :first_name
  def_delegator :user, :last_name

  include HasPaperclipImage
  has_paperclip_image styles: {form: "200x122>", hero: "330x330>", large: "590x525>"}, attr_accessible: true

  include HasPaperclipFile
  has_paperclip_file :petition_letter, attr_accessible: true

  attr_accessible :title, :who, :what, :why, :delivery_details,
                  :campaigner_contactable, :effort_id, :source, :group_id, :categorized_petitions_attributes, :location_id,
                  :share_on_facebook, :share_with_friends_on_facebook, :share_on_twitter, :share_via_email, :target_id, :external_facebook_page, :external_site

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

    string :location_country do
      location.country if location
    end

    string :location_region do
      location.region if location
    end


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
    self.signatures.order("created_at DESC").limit(10)
  end

  def recent_comments comment_start=0, comment_size=3
    return comments.where(id: nil) if prohibited? # activerecord scoping needs a scope, i wanted to return nothing so added this
    comments.visible.ordered_by_comments_over_time_gap.offset(comment_start).limit(comment_size)
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

  scope :awesome, launched.where(admin_status: :awesome, cancelled: false).order("updated_at DESC")

  scope :appropriate_unordered, launched.where(admin_status: APPROPRIATE_STATUSES, cancelled: false)
  scope :appropriate, appropriate_unordered.order("petitions.updated_at DESC")

  scope :awaiting_moderation, lambda { |organisation_id|
    launched.where(admin_status: [:unreviewed, :edited, :edited_inappropriate], organisation_id: organisation_id).order("updated_at DESC")
  }

  scope :ordered_by_location, lambda {|longitude, latitude, radius|
    radius = (radius || 25000) * 1609 # miles to meters
    distance_fragment = ActiveRecord::Base.send(:sanitize_sql_array, ["ST_Distance(locations.point, 'POINT(? ? 0)'::geography)", longitude, latitude])
    includes(:location).where("#{distance_fragment} < ?",  radius)
                       .order("#{distance_fragment} ASC")
  }

  scope :for_location, lambda {|longitude, latitude|
    includes(:target => :geography).where("ST_Within(ST_GeomFromText('POINT(#{longitude} #{latitude})', 4326), geographies.shape::geometry)")
  }

  def self.load_petition(slug)
    Petition.where(slug: slug).includes(:user).first!
  end

  def flags_count
    @flags_count ||= self.flags.created_after(self.administered_at).count
  end

  def signatures_count_key
    "#{id}_signatures_count"
  end

  def comments_count_key
    "petition_#{id}_comments_count"
  end

  def comments_cache_key
    comments_updated_at ? comments_updated_at.to_i : '1'
  end

  def signatures_size
    signatures.size
  end

  def comments_size
    comments.visible.size
  end

  def subscribed_signatures scope
    if scope.nil? || scope.empty?
      signatures.subscribed
    else
      signatures.subscribed.send(scope)
    end
  end

  def self.create_with_param(attrs)
    effort = attrs[:effort]
    target = attrs[:target]
    petition = Petition.new title: "#{effort.title_default}: #{target.name}", who: target.name,
                            what: effort.what_default, why: effort.why_default, image: effort.image_default
    
    petition.organisation = effort.organisation
    petition.location = target.location
    petition.categories << effort.categories
    petition.target = target
    petition.effort = effort
    petition
  end


  def self.featured_homepage_petitions(current_organisation)
    featured_effort = Effort.most_recently_featured(current_organisation)
    petitions = Petition.awesome.where(:organisation_id => current_organisation.id)

    if featured_effort.present?
      petitions = petitions.limit(2).all
      [featured_effort] + petitions
    else
      petitions.limit(3).all
    end
  end

  def schedule_reminder_email!
    Jobs::PromotePetitionJob.new.promote(self, :reminder_when_dormant)
  end

  def achieve_leading_progress!
    self.achievements[:leading_progress] = "lead"
    self.save!
  end

  def achieve_training_progress!
    self.achievements[:leading_progress] = "training"
    self.save!
  end

  def progress
    return "share" if shared?
    return "manage" if managed?
    achievements[:leading_progress]
  end

  def signature_counts_by_source
    signatures.group(:source).count(:source)
  end

  def email_from_address
    if user
      "\"#{user.full_name} via #{organisation.name}\" <#{organisation.contact_email}>"
    else
      "\"#{organisation.name}\" <#{organisation.contact_email}>"
    end
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

  def set_comments_updated_at_to_now
    self.comments_updated_at = Time.now
  end
end
