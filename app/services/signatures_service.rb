class SignaturesService < ApplicationService
  klass Signature

  set_callback :create, :after, :send_thank_you_and_promotion_emails, :if => "!halted && value"
  set_callback :create, :after, :notify_partner_org, :if => "!halted && value"
  set_callback :create, :after, :increment_petition_signatures_count, :if => "!halted && value"
  set_callback :create, :after, :increment_organisation_signatures_count, :if => "!halted && value"
  set_callback :create, :after, :increment_effort_signatures_count, :if => "!halted && value"
  set_callback :create, :after, :create_group_subscription, :if => "!halted && value"


  ENCOURAGEMENT_TARGET = 90
  ACHIEVEMENT_TARGET   = 100

  def delete(signature)
    signature.deleted_at = Time.now.utc
    save(signature)
    decrement_petition_signatures_count
    decrement_effort_signatures_count
    decrement_organisation_signatures_count
  end

  def save_while_launching(signature)
    @obj = signature
    if @obj.save
      increment_petition_signatures_count
      increment_effort_signatures_count
      increment_organisation_signatures_count
    end
  end

  def send_thank_you_and_promotion_emails
    SignatureMailer.delay.thank_signer(current_object)
    if current_object.petition.cached_signatures_size == ENCOURAGEMENT_TARGET
      Jobs::PromotePetitionJob.new.promote(current_object.petition, :encourage)
    elsif current_object.petition.cached_signatures_size == ACHIEVEMENT_TARGET
      Jobs::PromotePetitionJob.new.promote(current_object.petition, :achieved_goal)
    end

    true # to continue callback chain
  end

  def increment_petition_signatures_count
    update_petition_signatures_count do
      Rails.cache.increment(current_object.petition.signatures_count_key, 1,  raw: true)
    end
    true
  end

  def decrement_petition_signatures_count
    update_petition_signatures_count do
      Rails.cache.decrement(current_object.petition.signatures_count_key, 1,  raw: true)
    end
    true
  end

  def update_petition_signatures_count
    petition = current_object.petition
    if Rails.cache.read(petition.signatures_count_key).blank?
      Rails.cache.write(petition.signatures_count_key, petition.signatures_size, raw: true)
    else
      yield
    end
  end

  def increment_effort_signatures_count
    return if current_object.petition.effort.blank?
    update_effort_signatures_count do
      Rails.cache.increment(current_object.petition.effort.signatures_count_key, 1, raw: true)
    end
    true
  end

  def decrement_effort_signatures_count
    return if current_object.petition.effort.blank?
    update_effort_signatures_count do
      Rails.cache.decrement(current_object.petition.effort.signatures_count_key, 1, raw: true)
    end
    true
  end

  def update_effort_signatures_count
    effort = current_object.petition.effort
    if Rails.cache.read(effort.signatures_count_key).blank?
      Rails.cache.write(effort.signatures_count_key, effort.signatures_size, raw: true)
    else
      yield
    end
  end

  def increment_organisation_signatures_count
    update_organisation_signatures_count do
      Rails.cache.increment(current_organisation.signatures_count_key, 1, raw: true)
    end
    true
  end

  def decrement_organisation_signatures_count
    update_organisation_signatures_count do
      Rails.cache.decrement(current_organisation.signatures_count_key, 1, raw: true)
    end
    true
  end

  def update_organisation_signatures_count
    if Rails.cache.read(current_organisation.signatures_count_key).blank?
      Rails.cache.write(current_organisation.signatures_count_key, current_organisation.signatures.size, raw: true)
    else
      yield
    end
  end

  def notify_partner_org
    OrgNotifier.new.delay.notify_sign_up(organisation: current_object.petition.organisation, 
                                         petition: current_object.petition, user_details: current_object, role: 'signer')
    true
  end

  def create_group_subscription
    group = current_object.petition.group
    if group.present? && current_object.join_organisation == true
      GroupSubscription.subscribe!(current_object.member, group )
    end
    true
  end

  private
  def current_organisation
    current_object.petition.organisation
  end
end
