class Org::Efforts::TargetsController < Org::OrgController
  include LocationUpdateHelper

  before_filter :load_and_authorize
  before_filter :load_target, only: [:edit, :update, :remove]

  def new
    inherited_name = params[:target][:name] rescue ''
    @target = Target.new(name: inherited_name)
  end

  def create
    @target = Target.new(params[:target])
    @target.organisation = current_organisation
    @target.location = Location.find_by_query(params[:location][:query]) || Location.create(params[:location]) if params[:location]
    if @target.save
      create_petition_with_target(@target)
      redirect_to org_effort_path(params[:effort_id]), notice: "Created successfully!"
    else
      render :new
    end
  end

  def find
    @target = Target.new
  end

  def add
    @target = current_organisation.targets.where(name: params[:target][:name]).first

    if @target.blank?
      redirect_to new_org_effort_target_path(params)
    else
      petition = create_petition_with_target(@target)
      current_page = @effort.locate_petition(petition)
      redirect_to org_effort_path(params[:effort_id], page: current_page)
    end
  end

  def index
    result = Target.autocomplete(params[:term], current_organisation)
    render json: result
  end

  def edit
  end

  def update
    target_attributes = target_attributes_without_name

    if update_location(params[:location], target_attributes) && @target.update_attributes(target_attributes)
      update_related_petitions(location: @target.location)
      redirect_to org_effort_path(params[:effort_id]), notice: "Edited #{@target.name} successfully!"
    else
      render 'edit'
    end
  end

  def remove
    @petition = @effort.petitions.find_by_target_id @target.id
    @petition.effort = nil
    @petition.target = nil
    @petition.save
    redirect_to org_effort_path(@effort)
  end

  private

  def load_and_authorize
    @effort = Effort.find_by_slug params[:effort_id]
    raise ActiveRecord::RecordNotFound if @effort.organisation != current_organisation
    authorize_or_redirect! :manage, @effort
  end

  def load_target
    @target = Target.find_by_slug params[:id]
    raise ActiveRecord::RecordNotFound if @target.organisation != current_organisation
  end

  def target_attributes_without_name
    target_attributes = params[:target]
    target_attributes.delete(:name)
    target_attributes
  end

  def update_related_petitions(options={})
    if params[:location].present?
      @target.petitions.each do |petition|
        petition.location = options[:location]
        petition.save
      end
    end
  end

  def create_petition_with_target(target)
    petition = @effort.create_petition_with_target(target)
    petition.launched = true
    petition.admin_status = "good"
    petition.save
    petition
  end
end
