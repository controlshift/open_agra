class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include DeviseAfterSignInPath

  def setup
    # took me so long to find this working example
    # http://www.ur-ban.com/blog/2011/04/30/devise-omniauth-dynamic-providers/
    if current_organisation.enable_facebook_login?
      options = request.env['omniauth.strategy'].options
      options[:client_id] = current_organisation.fb_app_id
      options[:client_secret] = current_organisation.fb_app_secret
      options[:scope] = current_organisation.facebook_auth_scope
      options[:options] = { client_options: { ssl: { ca_path: '/usr/lib/ssl/certs/ca-certificates.crt' } } }
    end
    render text: "Setup complete.", status: 404
  end
      
  def facebook
    session[:facebook_access_token] = oauth_data.credentials.token
    session[:facebook_id] = oauth_data.uid
    session[:facebook_email] = info.email

    @token = oauth_params["token"]

    if current_user
      @user = current_user
    else
      @user = User.find_by_facebook_id_and_organisation_id(oauth_data.uid, current_organisation.id)
      if @user.blank?
        @user = User.find_by_email_and_organisation_id(oauth_data.info.email, current_organisation.id)
      end
    end
    
    if @user
      @user.facebook_id = oauth_data.uid
      @user.confirmed_at = Time.now

      @user.save!
      
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Facebook"
      sign_in_and_redirect @user, event: :authentication
    else
      @user = User.new(email: info.email, first_name: info.first_name, last_name: info.last_name, default_organisation_slug: current_organisation.slug)
      render 'users/registrations/completing'
    end
  end

  private

  def oauth_data
    request.env["omniauth.auth"]
  end

  def oauth_params
    request.env["omniauth.params"]
  end

  def info
    oauth_data.info
  end
end
