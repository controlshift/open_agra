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
#

class Group < ActiveRecord::Base
  has_many  :users, :through => :group_members
  has_many  :group_members
  belongs_to :organisation
  has_many :petitions
  has_many :signatures, :through => :petitions


  validates :title, presence: true
  validates :description, presence: true
  validates :organisation, presence: true

  include HasPaperclipImage
  has_paperclip_image styles: {hero: "330x330>", form: "200x122>"}
  include HasSlug

end
