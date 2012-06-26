require 'csv'

class Org::UsersController < Org::OrgController
  before_filter :load_and_authorize_user, except: [:index, :email, :export]

  def index
    @users = User.paginate page: params[:page], order: 'created_at DESC', conditions: {organisation_id: current_organisation.id}
    render 'admin/users/index'
  end

  def edit
    render 'admin/users/edit'
  end

  def update
    @user.attributes = User.extract_accessible_attributes_symbol_hash_values(params[:user])
    @user.org_admin = params[:user][:org_admin]
    if @user.save
      redirect_to org_users_path, notice: "#{@user.email} saved."
    else
      render 'admin/users/edit'
    end
  end

  def email
    @user = User.find_by_email_and_organisation_id params[:email], current_organisation.id
    if @user
      redirect_to edit_org_user_path(@user)
    else
      redirect_to org_users_path, alert: "Address Not Found"
    end

  end

  def export
    csv_string = Queries::People.new.people_as_csv(current_organisation.id)
    filename = "users-#{Time.now.strftime("%Y%m%d")}.csv"
    send_data(csv_string, type: 'text/csv; charset=utf-8; header=present', filename: filename)
  end

private

  def load_and_authorize_user
    @user = User.find(params[:id])
    authorize_or_redirect! :manage, @user
  end

end
