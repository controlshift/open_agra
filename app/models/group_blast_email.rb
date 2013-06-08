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

class GroupBlastEmail < BlastEmail
  validates :group_id, presence: true
  validate :max_three_emails_per_week, :on => :create

  validates_presence_of :moderation_reason, if: -> { self.moderation_status == 'inappropriate' }

  before_create :set_recipient_count
  
  def title
    group.title
  end

  def source
    group
  end

  def recipients
    group.subscriptions.subscribed
  end

  def new_email_path
    Rails.application.routes.url_helpers.new_group_email_path(group)
  end

  def can_be_unsubscribed?
    true
  end

  def sendgrid_category
    "G#{group.slug}_E#{from_address}"
  end

  private

  def set_recipient_count
    self.recipient_count = group.subscriptions.subscribed.size if group
  end

  def max_three_emails_per_week
    if GroupBlastEmail.where(group_id: group_id).where("created_at >= ? AND  moderation_status != ?", 7.days.ago, 'inappropriate').count >= 3
      errors.add(:group_id, I18n.t('errors.messages.max_three_emails_per_week'))
    end
  end
end
