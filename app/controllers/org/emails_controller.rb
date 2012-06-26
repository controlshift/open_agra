class Org::EmailsController < Org::OrgController
  def index
    @emails = PetitionBlastEmail.paginate(order: 'petition_blast_emails.created_at DESC', page: params[:page])
                                .joins(:petition).where(:petitions => {:organisation_id => current_organisation.id})
                                .includes(:petition)
  end

  def show
    @email = PetitionBlastEmail.find params[:id]
  end
  
  def moderation
    @emails = PetitionBlastEmail.awaiting_moderation(current_organisation).paginate(order: 'petition_blast_emails.created_at DESC', page: params[:page])
  end

  def update
    @email = PetitionBlastEmail.find params[:id]
    if @email.moderation_status == 'pending'
      @email.moderation_status = params[:petition_blast_email][:moderation_status]
      @email.moderation_reason = params[:petition_blast_email][:moderation_reason]

      if PetitionBlastEmailsService.new.save(@email)
        redirect_to moderation_org_emails_path
      else
        render :moderation
      end
    else
      redirect_to moderation_org_emails_path, :notice => 'You may not moderate this email multiple times.'
    end
  end
end