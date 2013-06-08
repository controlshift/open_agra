class Org::UsersController < Org::OrgController
  before_filter :load_and_authorize_user, except: [:index, :email, :export, :bad_postcodes]

  def index
    @users = User.paginate page: params[:page], order: 'created_at DESC', conditions: {organisation_id: current_organisation.id}
    render 'admin/users/index'
  end

  def bad_postcodes
    users = current_organisation.users
    @invalid_users = users.find_all{|u| !u.valid? }
  end

  def edit
    render 'admin/users/edit'
  end

  def update
    @user.additional_fields = {}
    @user.attributes = params[:user].slice( *@user.accessible_attribute_names )
    @user.org_admin = params[:user][:org_admin]
    if @user.save
      redirect_to org_members_path, notice: t('controllers.saved', value: @user.email)
    else
      render 'admin/users/edit'
    end
  end

  def email
    @user = User.find_by_email_and_organisation_id params[:email], current_organisation.id
    if @user
      redirect_to edit_org_user_path(@user)
    else
      redirect_to org_users_path, alert: t('errors.messages.address_not_found')
    end

  end

private

  def load_and_authorize_user
    @user = User.find(params[:id])
    raise ActiveRecord::RecordNotFound if @user.organisation != current_organisation
    authorize_or_redirect! :manage, @user
  end

end
