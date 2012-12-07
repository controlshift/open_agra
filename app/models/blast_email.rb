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

class BlastEmail < ActiveRecord::Base
  validates :from_name, presence: true, length: { maximum: 100 }, format: { :with => /\A([\p{Word} \.'\-]+)\Z/u }
  validates :from_address, presence: true, format: { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }
  validates :subject, presence: true, length: { maximum: 255 }
  validates :body, presence: true
  validates :type, presence: true
  validate :max_three_emails_per_week, :on => :create

  validates_presence_of :moderation_reason, if: -> { self.moderation_status == 'inappropriate' }

  RECIPIENT_MODERATION_LIMIT = 0
  DELIVERY_STATUSES   = 'pending', 'sending', 'delivered'
  MODERATION_STATUSES = 'pending', 'approved', 'inappropriate'

  scope :awaiting_moderation, lambda { |current_organisation |
    where(:moderation_status => "pending", :organisation_id => current_organisation.id)
  }

  validates :delivery_status, :inclusion => DELIVERY_STATUSES, :presence => true
  validates :moderation_status, :inclusion => MODERATION_STATUSES, :presence => true

  belongs_to :petition
  belongs_to :group
  belongs_to :organisation

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

  %W(pending inappropriate approved).each do |method|
    define_method("#{method}?") do
      moderation_status == method
    end
  end

  def available_to_moderate?
    pending?
  end

  def ready_to_send?
    approved? && !in_delivery?
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

  def source
    petition || group
  end

end
