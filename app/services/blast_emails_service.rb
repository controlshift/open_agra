class BlastEmailsService < ApplicationService
  klass BlastEmail

  set_callback :save,   :after,  :send_email_to_supporters,       :if => "!halted && value"
  set_callback :create, :before, :set_initial_moderation_status,  :if => "!halted"
  set_callback :save,   :before, :set_moderated_at,               :if => "!halted"

  def send_email_to_supporters
    if current_object.ready_to_send?
      ModerationMailer.delay.notify_campaigner_of_approval(current_object)
      current_object.send_to_all
    elsif current_object.moderation_status == "pending"
      ModerationMailer.delay.notify_admin_of_new_blast_email(current_object)
    elsif current_object.moderation_status == "inappropriate"
      ModerationMailer.delay.notify_campaigner_of_rejection(current_object)
    end
    true
  end

  def set_initial_moderation_status
    if current_object.recipient_count <= BlastEmail::RECIPIENT_MODERATION_LIMIT
      current_object.moderation_status = 'approved'
    end
    true
  end

  def set_moderated_at
    if current_object.moderation_status_changed?
      current_object.moderated_at = Time.now
    end
    true
  end
end