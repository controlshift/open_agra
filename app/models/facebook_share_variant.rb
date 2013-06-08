# == Schema Information
#
# Table name: facebook_share_variants
#
#  id                 :integer         not null, primary key
#  title              :string(255)
#  description        :text
#  type               :string(255)
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  petition_id        :integer
#  created_at         :datetime        not null
#  updated_at         :datetime        not null
#

class FacebookShareVariant < ActiveRecord::Base
  include HasPaperclipImage
  has_paperclip_image styles: { form: "200x200>" }, attr_accessible: true
  belongs_to :petition
  attr_accessible :title, :description, :image

  validates :title, presence:true

  def split_alternative
    @split_alternative ||= petition.facebook_share.experiment.alternatives.find{|alternative| alternative.name == self.id.to_s}
  end

  def participant_count
    if split_alternative
      split_alternative.participant_count
    else
      0
    end
  end

  def completed_count
    if split_alternative
      split_alternative.completed_count
    else
      0
    end
  end

  def rate
    if participant_count > 0
      completed_count.to_f / participant_count.to_f
    else
      0.0
    end
  end
end

