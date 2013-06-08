# == Schema Information
#
# Table name: blast_emails
#
#  id                :integer         not null, primary key
#  petition_id       :integer
#  from_name         :string(255)     not null
#  from_address      :string(255)     not null
#  subject           :string(255)     not null
#  body              :text            not null
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#  recipient_count   :integer
#  moderation_status :string(255)     default("pending")
#  delivery_status   :string(255)     default("pending")
#  moderated_at      :datetime
#  moderation_reason :text
#  type              :string(255)
#  group_id          :integer
#  organisation_id   :integer
#  target_recipients :string(255)
#

class BodyDefaultTextValidator < ActiveModel::Validator
  def validate(record)
    if record && record.body && record.body.include?(I18n.t('petition_blast_email.default_text'))
      record.errors['body'] << I18n.t('errors.messages.petition_blast_email.default_text')
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
    petition.subscribed_signatures(self.target_recipients)
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
      errors.add(:petition_id, I18n.t('errors.messages.max_three_emails_per_week'))
    end
  end
end
