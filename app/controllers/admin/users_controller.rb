class Admin::UsersController < Admin::AdminController
  before_filter :load_user, except: [:index, :email, :export]

  def index
    @users = User.paginate page: params[:page], order: 'created_at DESC'
  end

  def edit
  end

  def update
    @user.attributes = params[:user].slice( *@user.accessible_attribute_names )
    @user.admin = params[:user][:admin]
    @user.org_admin = params[:user][:org_admin]
    if @user.save
      redirect_to admin_users_path, notice: "#{@user.email} saved."
    else
      render :edit
    end
  end

  def email
    @user = User.find_by_email params[:email]
    if @user
      redirect_to edit_admin_user_path(@user)
    else
      redirect_to admin_users_path, alert: "Address Not Found"
    end

  end

private

  def load_user
    @user = User.find(params[:id])
  end
end
