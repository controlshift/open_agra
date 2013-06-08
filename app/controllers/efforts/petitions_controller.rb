class Efforts::PetitionsController < ApplicationController
  layout 'application_sidebar'
  skip_before_filter :authenticate_user!
  before_filter :load_effort
  before_filter :load_petition, except: [:new]
  before_filter :authorize_petition, except: [:new, :leading]

  def new
    @petition = Petition.new
    @petition.effort = @effort
    @petition.categories = @effort.categories

    if @effort.ask_for_location?
      @petition.location = Location.new
    end
  end

  def leading
    unless user_signed_in?
      session[:user_return_to] = training_effort_petition_path(@effort, @petition)
      session[:header_content] = "lead_petition_breadcrumb_steps"
      session[:petition_id] = @petition.id
      redirect_to new_user_registration_path(token: @petition.token)
    end
  end

  def lead
    PetitionsService.new.lead(@petition, current_user)
    redirect_to training_effort_petition_path(@effort, @petition)
  end

  def training
  end

  def train
    @petition.achieve_training_progress!
    redirect_to next_step_for_training_page(with_prompt_edit: @effort.prompt_edit_individual_petition, petition: @petition)
  end

  def edit
  end

  def update
    if @petition.update_attributes(params[:petition])
      redirect_to petition_manage_path(@petition)
    else
      render :edit
    end
  end

  private

  def next_step_for_training_page options
    options[:with_prompt_edit] ? edit_effort_petition_path(options[:petition].effort, options[:petition]) : petition_manage_path(options[:petition])
  end

  def load_effort
    @effort = Effort.find_by_slug(params[:effort_id])
    raise ActiveRecord::RecordNotFound if @effort.organisation != current_organisation
  end

  def load_petition
    @petition = Petition.where(slug: params[:id], organisation_id: current_organisation.id).first
    raise ActiveRecord::RecordNotFound if @petition.organisation != current_organisation
  end

  def authorize_petition
    lead_or_redirect_to_sign! :update, @petition
  end

  def lead_or_redirect_to_sign!(action, subject, *extra_args)
    if can?(action, subject, extra_args)
      return true
    else
      redirect_to petition_path(subject), :alert => t('controllers.efforts.petition.leader_exists')
      return false
    end
  end
end