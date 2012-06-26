class RegistrationsController < Devise::RegistrationsController
  prepend_before_filter :require_no_authentication, only: [:complete]
  
  def new
    defaults = {:email => params[:email]}
    resource = build_resource(defaults.delete_if {|key, value| value.blank? })
    respond_with resource
  end

  def create
    if is_user_registerable
      @petition = params[:token].blank? ? nil : Petition.find_by_token!(params[:token])
      super
      PetitionsService.new.link_petition_with_user!(@petition, resource) if @petition && resource.persisted?
    else
      flash[:alert] = "Did you receive an email with an invitation to use this site? If so, you can only register using that email address. You may have tried to use a different address; please click the back button and try again."
      redirect_to intro_path
    end
  end

  def completing
  end
  
  def complete
    build_resource

    if resource.valid?
      create
      if session[:facebook_id]
        resource.facebook_id = session[:facebook_id]
        resource.confirmed_at = Time.now
        resource.save!
      end
    else
      clean_up_passwords resource
      flash[:alert] = resource.errors.full_messages.join(", ")
      render :completing
    end
  end
  
  def is_user_registerable
    email = params[:user][:email]
    email.downcase! unless email.blank?
    email.blank? || EmailWhiteList.find_by_email(email) || current_organisation.skip_white_list_check?
  end

  def build_resource(hash=nil)
    hash ||= params[resource_name] || {}
    hash = User.extract_accessible_attributes_symbol_hash_values(hash)
    super(hash)
    self.resource.organisation = current_organisation
    if session[:facebook_email]
      # if you are creating an account while signed into facebook, you are only
      # allowed to create accounts for that user.
      raise('Someone is trying to hack the site!') if  (self.resource.email != session[:facebook_email])
    end
  end

  def after_sign_up_path_for(resource)
    @petition ? launch_petition_path(@petition) : super
  end

  def show_login_link
    false
  end
end
