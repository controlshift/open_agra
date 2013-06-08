class SessionsController < Devise::SessionsController
  include DeviseAfterSignInPath

  before_filter :load_organisation_id, only: [:create]

  def destroy
    super
    session[:facebook_access_token] = nil
  end
  
  private

  def load_organisation_id
    params[:user][:organisation_id] = current_organisation.id
  end

  def show_login_link
    false
  end

end
