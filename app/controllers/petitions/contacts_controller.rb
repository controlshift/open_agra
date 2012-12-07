class Petitions::ContactsController < ApplicationController
  include PetitionFilters

  before_filter :load_petition
  skip_before_filter :authenticate_user!
  before_filter :verify_petition_is_launched, only: [:contact]

  NOT_CONTACTABLE = {message: "The leader of this campaign may not be contacted.", error_type: "not_contactable"}
  CAPTCHA_NOT_MATCH = {message: "Text did not match with the image.", error_type: "captcha_failure"}
  EMAIL_SEND_FAILURE = {message: "Invalid input. Your email cannot be sent.", error_type: "email_send_failure"}

  def create
    return fail_response_with_error_message(error_message) if error_message.present?

    if contact_campaign_admins
      success_response
    else
      fail_response_with_error_message(EMAIL_SEND_FAILURE)
    end
  end

  # TODO: This should be refactored into a contact model.

  def fail_response_with_error_message(error_message)
    respond_to do |format|
      format.html { redirect_to petition_path(@petition), alert: error_message[:message] }
      format.json { render json: error_message, status: :not_acceptable }
    end
  end

  def success_response
    respond_to do |format|
      format.html { redirect_to petition_path(@petition), notice: "Your email has been sent to the campaigner" }
      format.json { render json: {}, status: :ok }
    end
  end

  def contactable?
    @petition.campaigner_contactable? || can?(:manage, @petition.organisation)
  end

  def error_message
    return NOT_CONTACTABLE unless contactable?
    return CAPTCHA_NOT_MATCH unless simple_captcha_valid?
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