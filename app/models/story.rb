# == Schema Information
#
# Table name: stories
#
#  id                 :integer         not null, primary key
#  title              :string(255)
#  content            :text
#  featured           :boolean
#  created_at         :datetime        not null
#  updated_at         :datetime        not null
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  organisation_id    :integer
#  link               :string(255)
#

require 'uri'

class Story < ActiveRecord::Base
  validates :title, presence: true
  validates :content, presence: true
  validates :link, allow_blank: true, format: URI::regexp(%w(http https))
  validate :cannot_exceed_max_length

  attr_accessible :title, :content, :featured, :link

  belongs_to :organisation

  include HasPaperclipImage
  has_paperclip_image styles: {hero: "590x525#"}, attr_accessible: true
  validates_attachment_presence :image
  
  scope :featured, where(featured: true)

  def self.featured_stories(current_organisation)
    featured.where(:organisation_id => current_organisation.id)
      .order("updated_at DESC")
      .all.rotate(-1)
  end

  private

  def cannot_exceed_max_length
    errors.add(:content, I18n.t('errors.messages.story.too_long')) if title &&
                                                                content && (title.length + content.length > 200 )
  end
end
