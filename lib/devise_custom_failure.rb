class DeviseCustomFailure < Devise::FailureApp
  def redirect_url
    if params.key?(:token) && !params[:token].empty?
      new_user_registration_path(:token => params[:token], :selectedtab => 'login')
    else
      super
    end
  end

  # You need to override respond to eliminate recall
  def respond
    if http_auth?
      http_auth
    else
      redirect
    end
  end
end