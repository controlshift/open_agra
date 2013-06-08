class RegistrationsController < Devise::RegistrationsController
  prepend_before_filter :require_no_authentication, only: [:complete]

  layout :layout_by_resource

  def new
    defaults = {email: params[:email], default_organisation_slug: current_organisation.slug}
    resource = build_resource(defaults.delete_if {|key, value| value.blank? })
    respond_with resource
  end

  def create
    if is_user_registerable?
      @petition = params[:token].blank? ? nil : Petition.find_by_token!(params[:token])
      super
      PetitionsService.new.link_petition_with_user!(@petition, resource) if @petition && resource.persisted?
    else
      flash[:alert] = t('controllers.registration.error_create')
      redirect_to intro_path
    end
  end

  def completing
  end
  
  def complete
    build_resource

    if resource_for_facebook_user_is_valid?
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

  private

  def layout_by_resource
    if session[:header_content] == "lead_petition_breadcrumb_steps"
      'application_sidebar'
    else
      'application'
    end
  end

  def resource_for_facebook_user_is_valid?
    # if you are creating an account while signed into facebook, you are only
    # allowed to create accounts for that user.
    raise(t('errors.messages.hacking')) if facebook_email_and_user_email_not_match?
    resource.valid?
  end

  def facebook_email_and_user_email_not_match?
    session[:facebook_email] && self.resource.email != session[:facebook_email]
  end

  def is_user_registerable?
    email = params[:user][:email]
    email.downcase! unless email.blank?
    email.blank? || EmailWhiteList.find_by_email(email) || current_organisation.skip_white_list_check?
  end

  def build_resource(hash={})
    super(default_organisation_slug: current_organisation.slug)
    self.resource.assign_attributes(params[resource_name] || hash)
    self.resource.organisation = current_organisation
    self.resource
  end

  def after_sign_up_path_for(resource)
    @petition.blank? ? super : session[:user_return_to]
  end

  def show_login_link
    false
  end
end
