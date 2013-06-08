class Petitions::AdminsController < ApplicationController
  before_filter :load_and_authorize_petition, except: [:show]
  before_filter :load_campaign_admin_and_petition, except: [:new, :create]
  skip_before_filter :authenticate_user!, only: [:show]

  layout 'application_sidebar'

  def new
    @campaign_admin = CampaignAdmin.new
    @admins = ([@petition.user] + @petition.campaign_admins).flatten.compact
  end

  def create
    invitation_email = params[:campaign_admin][:invitation_email]
    invitation = CampaignAdmin.find_by_invitation_email_and_petition_id(invitation_email, @petition.id)

    if @petition.user && invitation_email.strip.casecmp(@petition.email) == 0
      error t('controllers.petitions.admin.can_not_invite')
    elsif invitation || (invitation = create_invitation(invitation_email)).save
      InvitationMailer.delay.send_to_campaign_admin(invitation)

      flash[:notice] = t('controllers.petitions.admin.success_create', email: invitation_email)
      redirect_to new_petition_admin_path(@petition)
    else
      error invitation.errors.full_messages.join(',')
    end

  end

  def show
    if user_signed_in? && params_valid?
      if @petition.user.present?
        @campaign_admin.user = current_user
        @campaign_admin.save!
      else
        @petition.user = current_user
        @petition.save!
        @campaign_admin.destroy
      end
      redirect_to petition_manage_path(@petition)
    elsif user_signed_in?
      redirect_to root_path, alert: t('controllers.petitions.admin.invalid_token')
    else
      session[:user_return_to] = request.url
      redirect_to new_user_registration_path(email: @campaign_admin.invitation_email)
    end
  end

  def destroy
    if @campaign_admin.petition == @petition && @campaign_admin.destroy
      redirect_to new_petition_admin_path(@petition)
      flash[:notice] = t('controllers.petitions.admin.success_delete', email: @campaign_admin.invitation_email)
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  private
  
  def error(alert_message)
    flash[:alert] = alert_message
    @campaign_admin = CampaignAdmin.new
    @admins = [@petition.user] + @petition.campaign_admins
    render :new
  end

  def create_invitation(invitation_email)
    invitation = CampaignAdmin.new(invitation_email: invitation_email)
    invitation.petition = @petition
    invitation.user = User.find_by_email_and_organisation_id(invitation_email, current_organisation.id)
    invitation
  end

  def load_and_authorize_petition
    @petition = Petition.find_by_slug! params[:petition_id]
    raise ActiveRecord::RecordNotFound if @petition.organisation != current_organisation
    authorize_or_redirect! :manage, @petition
  end

  def load_campaign_admin_and_petition
    @campaign_admin = CampaignAdmin.find_by_id! params[:id]
    @petition = Petition.find_by_slug! params[:petition_id]
  end

  def params_valid?
    @campaign_admin.petition == @petition &&
        params[:campaign_admin].present? && params[:campaign_admin][:invitation_token].present? &&
        @campaign_admin.invitation_token == params[:campaign_admin][:invitation_token] &&
        @campaign_admin.invitation_email.strip.downcase == current_user.email.strip.downcase
  end
end