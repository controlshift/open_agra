class Admin::UsersController < Admin::AdminController
  before_filter :load_user, except: [:index, :email, :export, :jobs]

  def index
    @users = User.paginate page: params[:page], order: 'created_at DESC'
  end

  def edit
  end

  def update
    @user.additional_fields = {}
    @user.attributes = params[:user].slice( *@user.accessible_attribute_names )
    @user.admin = params[:user][:admin]
    @user.org_admin = params[:user][:org_admin]
    if @user.save
      redirect_to admin_users_path, notice: t('controllers.saved', :value => @user.email)
    else
      render :edit
    end
  end

  def email
    @user = User.find_by_email params[:email]
    if @user
      redirect_to edit_admin_user_path(@user)
    else
      redirect_to admin_users_path, alert: t('errors.messages.address_not_found')
    end

  end

  def jobs
    @jobs = []
    @jobs &&= CsvReport.displayable.paginate(:page => params[:page])
  end

private

  def load_user
    @user = User.find(params[:id])
  end
end
