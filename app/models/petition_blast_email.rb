# == Schema Information
#
# Table name: petition_blast_emails
#
#  id                :integer         not null, primary key
#  petition_id       :integer
#  from_name         :string(255)     not null
#  from_address      :string(255)     not null
#  subject           :string(255)     not null
#  body              :text            not null
#  delayed_job_id    :integer
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#  recipient_count   :integer
#  moderation_status :string(255)     default("pending")
#  delivery_status   :string(255)     default("pending")
#  moderated_at      :datetime
#  moderation_reason :string(255)
#

class BodyDefaultTextValidator < ActiveModel::Validator
  def validate(record)
    if record && record.body && record.body.include?("Not sure what to write? There are templates on the bottom half of the page that you can use")
      record.errors['body'] << "must not include the help text. Please remove it before sending your message."
    end
  end
end

class PetitionBlastEmail < ActiveRecord::Base
  validates :from_name, presence: true, length: { maximum: 100 }, format: { :with => /\A([\p{Word} \.'\-]+)\Z/u }
  validates :from_address, presence: true, format: { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }
  validates :subject, presence: true, length: { maximum: 255 }
  validates :body, presence: true
  validates :petition_id, presence: true
  validate :max_three_emails_per_week, :on => :create

  validates_presence_of :moderation_reason, if: -> { self.moderation_status == 'inappropriate' }
  validates_with BodyDefaultTextValidator

  RECIPIENT_MODERATION_LIMIT = 0
  DELIVERY_STATUSES   = 'pending', 'sending', 'delivered'
  MODERATION_STATUSES = 'pending', 'approved', 'inappropriate'

  validates :delivery_status, :inclusion => DELIVERY_STATUSES, :presence => true
  validates :moderation_status, :inclusion => MODERATION_STATUSES, :presence => true

  scope :awaiting_moderation, lambda { |current_organisation |
    where(:moderation_status => "pending", :petitions => {:organisation_id => current_organisation.id}).includes(:petition)
  }

  before_create :set_recipient_count
  
  belongs_to :petition
  
  attr_accessible :from_name, :from_address, :subject, :body
  
  def from
    "\"#{from_name}\" <#{from_address}>"
  end
  
  def send_test_email
    CampaignerMailer.email_supporters(self, [from_address], nil).deliver
  end
  
  def send_to_all
    self.update_attribute(:delivery_status, 'sending')
    job_handle = Delayed::Job.enqueue Jobs::BlastEmailJob.new(self)
    self.update_attribute(:delayed_job_id, job_handle.id)
  end

  def recipient_count
    if read_attribute(:recipient_count).present?
      read_attribute(:recipient_count)
    else
      set_recipient_count
    end
  end

  def available_to_moderate?
    pending?
  end

  def ready_to_send?
    approved? && !in_delivery?
  end

  def pending?
    moderation_status == 'pending'
  end

  def inappropriate?
    moderation_status == 'inappropriate'
  end

  def approved?
    moderation_status == 'approved'
  end

  def sending?
    delivery_status == 'sending'
  end

  def sent?
    delivery_status == 'delivered'
  end

  def in_delivery?
    sending? || sent?
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
