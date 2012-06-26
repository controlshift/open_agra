class Org::Groups::UsersController < Org::OrgController
  before_filter :load_and_authorize_group
  def index
    @users = @group.users order: 'created_at DESC'
  end

  def edit
    @user = User.find_by_id params[:id]
  end

  def update
    @user = User.find_by_id params[:id]
    gm = GroupMember.new(group: @group, user: @user)

    if gm.save
      redirect_to org_group_users_path(@group)
    else
      render :edit
    end
  end


  def destroy
    @user = User.find_by_id params[:id]
    @gm = GroupMember.first conditions: { group_id: @group.id, user_id: @user.id}

    if @gm.present? && @gm.destroy
      redirect_to org_group_users_path(@group)
    else
      redirect_to org_group_users_path(@group)
    end
  end

  private
  def load_and_authorize_group
    @group = Group.find_by_slug! params[:group_id]
    authorize_or_redirect! :manage, @group
  end
end
