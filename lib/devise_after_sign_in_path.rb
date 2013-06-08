module DeviseAfterSignInPath
  def token
    @token
  end

  def after_sign_in_path_for(resource)
    token = params[:token] || self.token
    if token.present?
      petition = Petition.find_by_token!(token)
      PetitionsService.new.link_petition_with_user!(petition, resource)
      session[:user_return_to] || petitions_path
    elsif session[:user_return_to].present? || request.env['omniauth.origin'].present?
      session[:user_return_to] || request.env['omniauth.origin'] 
    elsif resource.org_admin?
      org_path
    else
      petitions_path
    end
  end
end
