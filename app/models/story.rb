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

  private

  def cannot_exceed_max_length
    errors.add(:content, 'Total length of title and content is too long (maximum 200 characters).') if title &&
                                                                content && (title.length + content.length > 200 )
  end
end
