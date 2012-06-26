# == Schema Information
#
# Table name: efforts
#
#  id                        :integer         not null, primary key
#  organisation_id           :integer
#  title                     :string(255)
#  slug                      :string(255)
#  description               :text
#  gutter_text               :text
#  title_help                :string(255)
#  title_label               :string(255)
#  title_default             :text
#  who_help                  :string(255)
#  who_label                 :string(255)
#  who_default               :text
#  what_help                 :string(255)
#  what_label                :string(255)
#  what_default              :text
#  why_help                  :string(255)
#  why_label                 :string(255)
#  why_default               :text
#  created_at                :datetime        not null
#  updated_at                :datetime        not null
#  image_file_name           :string(255)
#  image_content_type        :string(255)
#  image_file_size           :integer
#  image_updated_at          :datetime
#  thanks_for_creating_email :text
#  ask_for_location          :boolean
#

class Effort < ActiveRecord::Base
  include HasSlug
  
  belongs_to :organisation
  has_many :petitions

  validates :title, presence: true
  validates :description, presence: true
  validates :organisation, presence: true
  validates_length_of :title, :slug, :title_label, :title_default, :who_label, :what_label, :why_label, maximum: 255

  include HasPaperclipImage
  has_paperclip_image styles: {hero: '330x330>', form: '200x122>'}

  def render(field, context)
    Liquid::Template.parse(self.send(field)).render(context)
  end

end
