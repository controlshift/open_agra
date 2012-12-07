class PetitionsController < ApplicationController
  include PetitionUpdateHelper
  include PetitionFilters

  skip_before_filter :authenticate_user!, only: [:new, :create, :contact, :search, :landing]

  before_filter :load_petition, except: [:index, :new, :create, :search, :landing]
  before_filter :authorize_petition, only: [:launch, :launching, :edit, :update]

  def index
    @petitions = current_user.manageable_petitions
    if @petitions.size == 1
      flash.keep
      redirect_to petition_manage_path(@petitions.first)
    end
  end

  def search
    begin
      @query = Queries::Petitions::DetailQuery.new(page: params[:page],
                                                   search_term: params[:q],
                                                   organisation: current_organisation)
      @query.execute!

      if @query.petitions.blank?
        featured_query = Queries::Petitions::CategoryQuery.new(page: nil, organisation: current_organisation)
        featured_query.execute!
        @featured_petitions = featured_query.petitions
      end
    rescue Errno::ECONNREFUSED
      flash.now.alert = "Failed to search. Please contact technical support."
    end
  end

  def new
    @petition = Petition.new
    session[:can_create_campaign] = true
  end

  def landing
    @petition = Petition.new
  end

  def create
    petition_attributes = attributes_for_petition(params[:petition])
    petition_attributes[:categorized_petitions_attributes] = attributes_for_categorized_petitions(@petition, params[:petition][:category_ids])

    @petition = Petition.new(petition_attributes)
    @petition.organisation = current_organisation
    @petition.user = current_user
    @petition.location = Location.find_by_query(params[:location][:query]) || Location.create(params[:location]) if params[:location]
    if @petition.effort.present?
      @petition.categories << @petition.effort.categories
    end

    petitions_service = PetitionsService.new
    if petitions_service.save(@petition)
      if user_signed_in?
        redirect_to launch_petition_path(@petition)
      else
        session[:header_content] = "start_petition_breadcrum_steps"
        session[:user_return_to] = launch_petition_path(@petition)
        redirect_to new_user_registration_path(token: @petition.token)
      end
    else
      render :new
    end
  end

  def edit
    render :new
  end

  def update
    @success = update_petition(@petition, params[:petition], params[:location])
    if @success
      respond_to do |format|
        format.html { redirect_to launch_petition_path(@petition) }
        format.js { render layout: false }
      end
    else
      respond_to do |format|
        format.html { render :new }
        format.js { render layout: false }
      end
    end
  end

  def launching
    @signature = Signature.new(default_organisation_slug: current_organisation.slug)
  end

  def launch
    if current_organisation.requires_user_confirmation_on_sign_up? && !current_user.confirmed?
      session["after_confirmation_path"] = launch_petition_path(@petition)
      redirect_to new_user_confirmation_path
    else
      PetitionsService.new.launch(@petition, current_user)
      redirect_to petition_manage_path(@petition)
    end
  end

  private

  def load_petition
    @petition = Petition.where(slug: params[:id]).includes(:user).first!
    raise ActiveRecord::RecordNotFound if @petition.organisation != current_organisation
  end

  def authorize_petition
    authorize_or_redirect! :manage, @petition
  end
end
