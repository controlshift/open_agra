# == Schema Information
#
# Table name: efforts
#
#  id                              :integer         not null, primary key
#  organisation_id                 :integer
#  title                           :string(255)
#  slug                            :string(255)
#  description                     :text
#  gutter_text                     :text
#  title_help                      :text
#  title_label                     :string(255)
#  title_default                   :text
#  who_help                        :text
#  who_label                       :string(255)
#  who_default                     :text
#  what_help                       :text
#  what_label                      :string(255)
#  what_default                    :text
#  why_help                        :text
#  why_label                       :string(255)
#  why_default                     :text
#  created_at                      :datetime
#  updated_at                      :datetime
#  image_file_name                 :string(255)
#  image_content_type              :string(255)
#  image_file_size                 :integer
#  image_updated_at                :datetime
#  thanks_for_creating_email       :text
#  ask_for_location                :boolean
#  effort_type                     :string(255)     default("open_ended")
#  leader_duties_text              :text
#  how_this_works_text             :text
#  training_text                   :text
#  training_sidebar_text           :text
#  distance_limit                  :integer         default(100)
#  prompt_edit_individual_petition :boolean         default(FALSE)
#  featured                        :boolean         default(FALSE)
#  image_default_file_name         :string(255)
#  image_default_content_type      :string(255)
#  image_default_file_size         :integer
#  image_default_updated_at        :datetime
#  landing_page_welcome_text       :text
#

class Effort < ActiveRecord::Base
  include HasSlug
  include Progress

  belongs_to :organisation
  has_many :petitions
  has_many :categorized_efforts
  has_many :categories, through: :categorized_efforts

  validates :title, presence: true
  validates :description, presence: true
  validates :organisation, presence: true
  validates_length_of :title, :slug, :title_label, :title_default, :who_label, :what_label, :why_label, maximum: 255
  validates :title_default, :what_default, :why_default, :leader_duties_text,
            :how_this_works_text, :training_text, :training_sidebar_text,
            :presence => {if: :specific_targets?}
  validates :distance_limit, :numericality => { only_integer: true, greater_than: 0}, allow_blank: true, allow_nil: true

  include HasPaperclipImage
  has_paperclip_image styles: {hero: '330x330>', form: '200x122>'}

  has_attached_file :image_default, Rails.configuration.paperclip_options.merge(styles: {hero: '330x330>', form: '200x122>'})
  validates_attachment_content_type(:image_default, content_type: /image\/.+/, message: "must be an image file")

  EFFORT_TYPES = %w(open_ended specific_targets)
  validates_inclusion_of :effort_type, in: EFFORT_TYPES

  scope :featured, where(featured: true).order("updated_at DESC")

  scope :most_recently_featured, lambda { |organisation_id|
    featured.where(organisation_id: organisation_id).limit(1)
  }

  searchable do
    text(:categories) do
      categories.map { |category| category.name }
    end
  end

  def render(field, context)
    Liquid::TemplateCache.render(context, "#{self.cache_key}_#{field}", self.send(field))
  end

  def create_petition_with_target(target)
    petition = petitions.find_by_target_id(target.id)
    return petition if petition.present?
    petition_attrs = {target: target, effort: self}
    Petition.create_with_param petition_attrs
  end

  def locate_petition(petition)
    petition_index = petitions.order('created_at DESC').to_a.index(petition)

    page_index_of_petition(WillPaginate.per_page, petition_index)
  end

  def page_index_of_petition(per_page, petition_index)
    ((petition_index*1.0+1)/per_page).ceil
  end

  def open_ended?
    effort_type == 'open_ended'
  end

  def specific_targets?
    effort_type == 'specific_targets'
  end

  def self.create_from_params params
    if params[:effort_type] == "specific_targets"
      params.delete(:who_default)
      params.merge!(ask_for_location: true)
    else
      [:leader_duties_text, :how_this_works_text, :training_text, :training_sidebar_text].each { |p| params.delete(p) }
    end
    new params
  end

  def petition_locations
    petitions.appropriate.where("petitions.location_id is not null").collect { |petition| petition.location }
  end

  def order_petitions_by_location(location)
    return self.petitions.appropriate unless location
    latitude = location[:latitude].to_f
    longitude = location[:longitude].to_f

    query = Queries::Petitions::EffortLocationQuery.new(organisation: organisation,
                                                        latitude: latitude, longitude: longitude, effort: self)
    query.execute!
    query.petitions
  end

  def signatures_size
    petitions.inject(0) { |result, petition| result + petition.cached_signatures_size }
  end

  def signatures_count_key
    "#{id}_effort_signatures_count"
  end

  def default_welcome_email_in_organisation organisation
    Content.for_slug_and_organisation('welcome_email', organisation)
  end

  def default_petition_image
    self.image_default.present? ? self.image_default : nil
  end

  {'how_this_works_text' => 'how_this_works_text',
   'leader_duties_text' => 'leader_duties_text',
   'thanks_for_creating_email' => 'welcome_email',
   'training_text' => 'training_text',
   'training_sidebar_text' => 'training_sidebar_text'}.each do |desc, text_file|
    define_method "#{desc}_in_organisation" do |organisation|
      self.send("#{desc}") or Content.for_slug_and_organisation("#{text_file}", organisation).body rescue "please run rake db:seed_fu"
    end
  end


end
