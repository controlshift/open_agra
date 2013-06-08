# == Schema Information
#
# Table name: groups
#
#  id                 :integer         not null, primary key
#  organisation_id    :integer
#  title              :string(255)
#  slug               :string(255)
#  description        :text
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  created_at         :datetime        not null
#  updated_at         :datetime        not null
#  settings           :text
#

class Group < ActiveRecord::Base
  include BooleanFields

  has_many  :users, :through => :group_members
  has_many  :group_members
  belongs_to :organisation
  has_many :petitions
  has_many :signatures, through: :petitions
  has_many :subscriptions, class_name: 'GroupSubscription'

  store :settings, accessors: [:signature_disclaimer, :opt_in_label, :display_opt_in]
  boolean_fields :display_opt_in

  validates :opt_in_label, presence: true, if: :display_opt_in?

  validates :title, presence: true
  validates :description, presence: true
  validates :organisation, presence: true

  include HasPaperclipImage
  has_paperclip_image styles: {hero: "330x330>", form: "200x122>"}
  include HasSlug

  def subscribed_signatures
    signatures.subscribed.all.uniq { |s| s.email }
  end

  def cached_signatures_size
    petitions.inject(0) { |result, petition| result + petition.cached_signatures_size }
  end
end
