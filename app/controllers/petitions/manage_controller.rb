class Petitions::ManageController < ApplicationController
  include PetitionFilters
  include PetitionUpdateHelper

  before_filter :load_and_authorize_petition
  before_filter :verify_petition_can_be_managed, except: [:show, :edit, :update, :contact_admin]
  before_filter :verify_petition_is_launched

  layout :set_layout

  def show
    if @petition.prohibited?
      @email = Email.new
      render "show_inappropriate", layout: "application"
    else
      render :show
    end
  end

  def update
    @success = update_petition(@petition, params[:petition], params[:location])
    if @success
      respond_to do |format|
        format.html { redirect_to petition_path(@petition), notice: t('controllers.petitions.manage.success_update') }
        format.js { render layout: false }
      end
    else
      respond_to do |format|
        format.html { render :edit }
        format.js { render layout: false }
      end
    end
  end
  
  def check_alias
    @petition.alias = params[:alias]
    if @petition.valid? || !@petition.errors.has_key?(:alias)
      render json: {}, status: :ok
    else
      render json: { message: @petition.errors[:alias].first }, status: :not_acceptable
    end
  end
  
  def update_alias
    @petition.alias = params[:alias]
    if @petition.save
      render json: { url: petition_alias_url(@petition.alias) }, status: :ok
    else
      render json: { message: t('controllers.petitions.manage.error_update_alias') }, status: :not_acceptable
    end
  end

  def download_letter
    if @petition.cached_signatures_size > 500
      Jobs::GeneratePetitionLetterJob.perform_async(@petition.id, "#{@petition.slug}_form.pdf", current_user.id)
      redirect_to deliver_petition_manage_path(@petition), notice: t('controllers.petitions.manage.download_message', email: current_user.email)
    else
      output = Documents::PetitionLetter.new(petition: @petition).render
      send_data output, filename: "#{@petition.slug}_letter.pdf", type: "application/pdf"
    end
  end

  def download_form
    output = Documents::PetitionForm.new(petition: @petition).render
    send_data output, filename: "#{@petition.slug}_form.pdf", type: "application/pdf"
  end

  def cancel
    @petition.cancelled = true
    PetitionsService.new.save(@petition)
    redirect_to petition_manage_path(@petition)
  end

  def activate
    @petition.cancelled = false
    PetitionsService.new.save(@petition)
    redirect_to petition_manage_path(@petition), notice: t('controllers.petitions.manage.success_activate')
  end

  def contact_admin
    @email = Email.new(params[:email])
    @email.from_name = @petition.user.full_name
    @email.from_address = @petition.user.email
    @email.to_address = current_organisation.admin_email

    if @email.save
      UserMailer.delay.contact_admin(@petition, @email)
      redirect_to petition_manage_path(@petition), notice: t('controllers.petitions.manage.success_submission')
    else
      render :show_inappropriate
    end
  end

  private

  def load_and_authorize_petition
    @petition = Petition.find_by_slug!(params[:petition_id])
    authorize! :manage, @petition, message: t('unauthorized.default')
    raise  ActiveRecord::RecordNotFound  if @petition.organisation != current_organisation
  end

  def set_layout
    if request.headers['X-PJAX']
      'pjax'
    else
      'application_sidebar'
    end
  end

end
