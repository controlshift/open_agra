class Petitions::ContactsController < ApplicationController
  include PetitionFilters

  before_filter :load_petition
  skip_before_filter :authenticate_user!
  before_filter :verify_petition_is_launched, only: [:contact]

  def new
    @email = Email.new
    render partial: "shared/contact_user_form", locals: { user: @petition.user, url: petition_contacts_path(@petition) }
  end

  def create
    return fail_response_with_error_message(error_message) if error_message.present?

    if contact_campaign_admins
      success_response
    else
      fail_response_with_error_message({message: t('controllers.petitions.contact.email_send_failure'), error_type: "email_send_failure"})
    end
  end

  private
  # TODO: This should be refactored into a contact model.

  def fail_response_with_error_message(error_message)
    respond_to do |format|
      format.html { redirect_to petition_path(@petition), alert: error_message[:message] }
      format.json { render json: error_message, status: :not_acceptable }
    end
  end

  def success_response
    respond_to do |format|
      format.html { redirect_to petition_path(@petition), notice: t('controllers.petitions.contact.success_email') }
      format.json { render json: {}, status: :ok }
    end
  end

  def contactable?
    @petition.campaigner_contactable? || can?(:manage, @petition.organisation)
  end

  def error_message
    return {message: t('controllers.petitions.contact.not_contactable'), error_type: "not_contactable"} unless contactable?
    return {message: t('controllers.petitions.contact.captcha_failure'), error_type: "captcha_failure"} unless simple_captcha_valid?
  end


  def contact_campaign_admins
    result = true
    @petition.admins.each do |campaign_admin|
      email = Email.new(params[:email].merge(to_address: campaign_admin.email))
      result = email.save
      break unless result
      UserMailer.delay.contact_campaigner(@petition, email)
    end
    result
  end


  def load_petition
    @petition = Petition.where(slug: params[:petition_id]).first!
    raise ActiveRecord::RecordNotFound if @petition.organisation != current_organisation
  end
end