class ApplicationController < ActionController::Base
  include OrganisationHelpers
  protect_from_forgery

  before_filter :authenticate_user!
  before_filter :prepend_organisation_view_path

  helper_method :show_login_link

  use_vanity :current_user

  protected

  def show_login_link
    true
  end

  def prepend_organisation_view_path
    prepend_view_path(private_organisations_view_path)
  end

  def facebook_access_token
    session[:facebook_access_token]
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, alert: exception.to_s
  end

  rescue_from FbGraph::InvalidToken do |exception|
    sign_out current_user
    redirect_to new_user_session_path, alert: "Facebook session has expired, please log in again."
  end

  def authorize_or_redirect!(action, subject, *extra_args)
    if can?(action, subject, extra_args)
      # continue
      return true
    else
      # redirect & halt filter chain
      redirect_to root_path, :alert => 'You are not authorized to view that page.'
      return false
    end
  end

  private

  def private_organisations_view_path
    File.join(AgraPrivate::Engine.paths["app/views"].existent, "organisations/#{current_organisation.slug}")
  end
end
