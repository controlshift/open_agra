# == Schema Information
#
# Table name: comments
#
#  id            :integer         not null, primary key
#  text          :text
#  up_count      :integer         default(0)
#  approved      :boolean
#  flagged_at    :datetime
#  flagged_by_id :integer
#  signature_id  :integer
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#  featured      :boolean         default(FALSE)
#

class Comment < ActiveRecord::Base
  include FullName

  attr_accessible :text, :up_count

  validates :text, length: {minimum: 10, maximum: 500}
  validates :signature_id, uniqueness: true

  belongs_to :signature
  belongs_to :flagged_by, :class_name => 'User' 

  scope :visible, where('approved = true OR (flagged_at IS NULL AND approved IS NULL)')

  scope :ordered_by_comments_over_time_gap, order("(comments.up_count + 1)*60*60*24/EXTRACT(EPOCH FROM now() - comments.created_at) desc")

  scope :awaiting_moderation, lambda { |organisation_id|
    joins(:signature => :petition).where('petitions.organisation_id = ?', organisation_id)
    .where('comments.approved is null and comments.flagged_at is not null').includes(:signature => :petition).order('flagged_at DESC')
  }

  scope :display_columns, select("comments.id, comments.created_at, comments.approved, comments.signature_id, comments.text, signatures.first_name as signature_first_name, signatures.last_name as signature_last_name")

  strip_attributes only: [:text]

  def first_name
    if self.respond_to?(:signature_first_name)
      self.signature_first_name
    else
      signature.first_name
    end
  end

  def last_name
    if self.respond_to?(:signature_last_name)
      self.signature_last_name
    else
      signature.last_name
    end
  end

  def created_at_iso_8601
    created_at.strftime("%Y-%m-%dT%H:%M:%SZ")
  end

  def visible?
    approved? || (!flagged? && !approved?)
  end

  def hidden?
    !visible?
  end

  def flagged?
    !!flagged_at
  end

  def awaiting_approval?
    !approved?
  end
end
