require 'will_paginate/array'
class Org::EmailsController < Org::OrgController
  def index
    @emails = BlastEmail.where(:organisation_id => current_organisation.id).paginate(order: 'blast_emails.created_at DESC', page: params[:page])
  end

  def show
    @email = BlastEmail.find params[:id]
  end
  
  def moderation
    @emails = BlastEmail.awaiting_moderation(current_organisation).paginate(order: 'blast_emails.created_at DESC', page: params[:page])
  end

  def update
    @email = BlastEmail.find params[:id]

    blast_email_status = params.has_key?(:petition_blast_email) ? params[:petition_blast_email] : params[:group_blast_email]

    if @email.moderation_status == 'pending'
      @email.moderation_status = blast_email_status[:moderation_status]
      @email.moderation_reason = blast_email_status[:moderation_reason]

      if BlastEmailsService.new.save(@email)
        redirect_to moderation_org_emails_path
      else
        if @email.errors[:moderation_reason].any?
          flash[:notice] = t('controllers.org.email.moderation_reason_blank')
        else
          flash[:notice] = t('controllers.org.email.error_update')
        end
        render :show
      end
    else
      redirect_to moderation_org_emails_path, :notice => t('controllers.org.email.moderation_not_allowed')
    end
  end
end