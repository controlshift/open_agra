# == Schema Information
#
# Table name: blast_emails
#
#  id                :integer         not null
#  petition_id       :integer
#  from_name         :string(255)     not null
#  from_address      :string(255)     not null
#  subject           :string(255)     not null
#  body              :text            not null
#  delayed_job_id    :integer
#  created_at        :datetime
#  updated_at        :datetime
#  recipient_count   :integer
#  moderation_status :string(255)     default("pending")
#  delivery_status   :string(255)     default("pending")
#  moderated_at      :datetime
#  moderation_reason :text
#  type              :string(255)
#  group_id          :integer
#  organisation_id   :integer
#

class BodyDefaultTextValidator < ActiveModel::Validator
  def validate(record)
    if record && record.body && record.body.include?("Not sure what to write? There are templates on the bottom half of the page that you can use")
      record.errors['body'] << "must not include the help text. Please remove it before sending your message."
    end
  end
end

class PetitionBlastEmail < BlastEmail
  validates :petition_id, presence: true
  validate :max_three_emails_per_week, :on => :create

  validates_with BodyDefaultTextValidator

  before_create :set_recipient_count
  
  def title
    petition.title
  end

  def source
    petition
  end

  def recipients
    petition.subscribed_signatures
  end

  def new_email_path
    Rails.application.routes.url_helpers.new_petition_email_path(petition)
  end

  def can_be_unsubscribed?
    true
  end

  def sendgrid_category
    "P#{petition.slug}_E#{from_address}"
  end

  private

  def set_recipient_count
    self.recipient_count = petition.signatures.subscribed.size if petition
  end

  def max_three_emails_per_week
    if PetitionBlastEmail.where(petition_id: petition_id).where("created_at >= ? AND  moderation_status != ?", 7.days.ago, 'inappropriate').count >= 3
      errors.add(:petition_id, "can have a maximum of three emails in a week.")
    end
  end
end
