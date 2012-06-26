module DeviseAfterSignInPath
  def after_sign_in_path_for(resource)
    token = params[:token] || @token
    if token.present?
      petition = Petition.find_by_token!(token)
      PetitionsService.new.link_petition_with_user!(petition, resource)
      launch_petition_path(petition)
    elsif session[:user_return_to].present?
      session[:user_return_to]
    else
      petitions_path
    end
  end
end
