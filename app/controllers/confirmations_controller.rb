class ConfirmationsController < Devise::ConfirmationsController
  before_filter :redirect_if_confirmed, only: [:new, :create, :show] 
  
  def after_resending_confirmation_instructions_path_for(resource_name)
    new_user_confirmation_path
  end

  def after_confirmation_path_for(resource_name, resource)
    session["after_confirmation_path"] || petitions_path
  end

  def redirect_if_confirmed
    if current_user
      if current_user.confirmed?
        flash[:notice] = t('controllers.confirmation.already_confirmed')
        redirect_to session["after_confirmation_path"] || petitions_path
      end
    else
      redirect_to new_user_session_path
    end
  end
end
