class Org::EffortsController < Org::OrgController
  before_filter :load_and_authorize_effort, only: [:edit, :update, :show]

  def index
    @efforts = Effort.paginate(page: params[:page]).order('created_at DESC').where(organisation_id: current_organisation.id)
  end

  def show
    @petitions = Petition.where(effort_id: @effort).paginate(page: params[:page]).order('created_at DESC')
  end

  def new
    @effort = Effort.new
  end

  def create
    @effort = Effort.new params[:effort]
    @effort.organisation = current_organisation
    if @effort.save
      redirect_to org_effort_path(@effort)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @effort.update_attributes(params[:effort])
      redirect_to org_effort_path(@effort)
    else
      render :edit
    end
  end



  private
  def load_and_authorize_effort
    @effort = Effort.find_by_slug! params[:id]
    authorize_or_redirect! :manage, @effort
  end
end