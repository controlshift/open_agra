class PasswordsController < Devise::PasswordsController
  include OrganisationHelpers
  
  before_filter :set_organisation_id, only: [:create]
  
  def set_organisation_id
    params[:user][:organisation_id] = @current_organisation.id
  end
end