class GroupsController < ApplicationController
  skip_before_filter :authenticate_user!, only: [:show]

  def index
    @groups = current_user.groups
    
    if @groups.size == 1
      flash.keep
      redirect_to group_manage_path(@groups.first)
    end
  end

  def show
    @group = Group.find_by_slug!(params[:id])
    raise ActiveRecord::RecordNotFound if @group.organisation != current_organisation
    @petitions = @group.petitions.appropriate.paginate page: params[:page]
  end
end