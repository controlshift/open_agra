class Org::GroupsController < Org::OrgController
  before_filter :load_and_authorize_group, only: [:edit, :update, :show]

  def index
    @groups = Group.paginate(order: 'groups.created_at DESC', page: params[:page]).where(:organisation_id => current_organisation.id)
  end

  def show
  end

  def new
    @group = Group.new
  end

  def create
    @group = Group.new params[:group]
    @group.organisation = current_organisation
    if @group.save
      redirect_to org_group_path(@group)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @group.update_attributes(params[:group])
      redirect_to org_group_path(@group)
    else
      render :edit
    end
  end

  private
  def load_and_authorize_group
    @group = current_organisation.groups.where(slug: params[:id]).first!
    raise ActiveRecord::RecordNotFound if @group.organisation != current_organisation
    authorize_or_redirect! :manage, @group
  end
end