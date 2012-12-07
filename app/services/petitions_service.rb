class PetitionsService < ApplicationService
  klass Petition

  set_callback :create, :after, :send_creation_thank_you_and_schedule_launch_reminder, :if => "!halted && value"
  set_callback :update, :before, :notify_petition_being_marked_as_inappropriate, :if => "!halted"
  set_callback :update, :after, :notify_petition_being_edited_by_campaigner, :if => "!halted"

  def send_creation_thank_you_and_schedule_launch_reminder
    if current_object.user
      actions_after_petition_is_created_and_has_user
    end

    true
  end

  def link_petition_with_user!(petition, user)
    self.current_object= petition
    return if petition.user.present?
    current_object.user = user
    current_object.save!
    actions_after_petition_is_created_and_has_user
  end

  def notify_petition_being_marked_as_inappropriate
    if @obj.valid? && @obj.admin_status == :inappropriate && @obj.admin_status_changed?
      CampaignerMailer.delay.notify_petition_being_marked_as_inappropriate(@obj)
    end

    true
  end

  def launch(petition, current_user)
    if petition.cached_signatures_size == 0
      signature = petition.signatures.build({default_organisation_slug: petition.organisation.slug})
      signature_attributes = current_user.signature_attributes(signature)
      signature.assign_attributes( signature_attributes )
      raise "invalid signature" if !signature.valid?
      SignaturesService.new.save_while_launching(signature)
      petition.schedule_reminder_email!
    end
    petition.launched = true
    petition.save!
    petition
  end

  def lead(petition, current_user)
    petition.user = current_user
    petition.achieve_leading_progress!
    petition.save!
    launch(petition, current_user)
  end
  
  def notify_petition_being_edited_by_campaigner
    if current_object.admin_status == :edited_inappropriate || current_object.admin_status == :edited
      ModerationMailer.delay.notify_admin_of_edited_petition(current_object)
    end

    true
  end

  private

  def actions_after_petition_is_created_and_has_user
    CampaignerMailer.delay.thanks_for_creating(current_object)
    ModerationMailer.delay.notify_admin_of_new_petition(current_object)
    Jobs::PromotePetitionJob.new.promote(current_object, :send_launch_kicker)
    OrgNotifier.new.delay.notify_sign_up(organisation: current_object.organisation, petition: current_object, 
                                         user_details: current_object.user, role: 'creator')
  end
end
