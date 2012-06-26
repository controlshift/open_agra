class PetitionsController < ApplicationController
  include PetitionAttributesHelpers
  
  skip_before_filter :authenticate_user!, only: [:new, :create, :contact, :search, :landing]

  before_filter :load_petition, except: [:index, :new, :create, :search, :landing]
  before_filter :authorize_petition, only: [:share, :launch, :launching, :edit, :update]
  before_filter :verify_petition_is_launched, only: [:share, :contact]

  def index
    @petitions = current_user.manageable_petitions.sort {|x,y| y.updated_at <=> x.updated_at }
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
    @petition.location =  Location.find_by_query(params[:location][:query]) || Location.create(params[:location]) if params[:location]

    petitions_service = PetitionsService.new
    if petitions_service.save(@petition)
      if user_signed_in?
        redirect_to launch_petition_path(@petition)
      else
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
    petition_attributes = attributes_for_petition(params[:petition])
    petition_attributes[:categorized_petitions_attributes] = attributes_for_categorized_petitions(@petition, params[:petition][:category_ids])
    if @success = PetitionsService.new.update_attributes(@petition, petition_attributes)
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
    @signature = Signature.new
  end

  def launch
    if current_organisation.requires_user_confirmation_on_sign_up? && !current_user.confirmed?
      session["after_confirmation_path"] = launch_petition_path(@petition)
      redirect_to new_user_confirmation_path
    else
      if @petition.cached_signatures_size == 0
        @signature = Signature.new(current_user.accessible_attributes_hash_values)
        @signature.petition = @petition
        SignaturesService.new.save_while_launching(@signature)
        schedule_reminder_email
      end
      track! :launch_petition
      @petition.launched = true
      @petition.save!
      redirect_to share_petition_path(@petition)
    end
  end

  def share
  end

  def contact
    respond_to do |format|
      if @petition.campaigner_contactable? || can?(:manage, @petition.organisation)
        if send_email_to_campaign_admins
          format.html { redirect_to petition_path(@petition), notice: "Your email has been sent to the campaigner" }
          format.json { render json: {}, status: :ok }
        else
          format.html { redirect_to petition_path(@petition), alert: "Invalid input. Your email cannot be sent." }
          format.json { render json: {message: "Invalid input. Your email cannot be sent."}, status: :not_acceptable }
        end
      else
        format.html { redirect_to petition_path(@petition), alert: "This campaigner doesn't want to be contacted at the moment." }
        format.json { render json: {message: "This campaigner doesn't want to be contacted at the moment."}, status: :not_acceptable }
      end
    end
  end

  def send_email_to_campaign_admins
    result = true
    @petition.admins.each do |campaign_admin|
      email = Email.new(params[:email].merge(to_address: campaign_admin.email))
      result = email.save
      break if !result
      UserMailer.delay.contact_campaigner(@petition, email)
    end
    result
  end

  private

  def load_petition
    @petition = Petition.where(slug: params[:id]).includes(:user).first!
  end

  def authorize_petition
    authorize_or_redirect! :manage, @petition
  end

  include PetitionFilters

  def schedule_reminder_email
    Jobs::PromotePetitionJob.new.promote(@petition, :reminder_when_dormant)
  end
end
