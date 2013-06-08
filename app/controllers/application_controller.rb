class ApplicationController < ActionController::Base
  include OrganisationHelpers
  helper FacebookShareWidget::Engine.helpers
  include SimpleCaptcha::ControllerHelpers

  protect_from_forgery

  before_filter :authenticate_user!, :prepend_organisation_view_path,  :set_locale

  helper_method :show_login_link

  rescue_from OrganisationNotFoundException, :with => :organisation_not_found

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
    redirect_to new_user_session_path, alert: t('controllers.application.fb_session_expired')
  end

  def authorize_or_redirect!(action, subject, *extra_args)
    if can?(action, subject, extra_args)
      # continue
      return true
    else
      # redirect & halt filter chain
      redirect_to root_path, :alert => t('unauthorized.default')
      return false
    end
  end

  private

  def set_locale
    return if self.request.headers['HTTP_ACCEPT_LANGUAGE'].blank?
    user_languages = self.request.headers['HTTP_ACCEPT_LANGUAGE'].split(',').collect {|val| val.split(';')[0]}
    displayable_langs = user_languages - (user_languages - I18n.available_locales.collect(&:to_s))
    I18n.locale = displayable_langs[0] || I18n.default_locale
  end
  
  def private_organisations_view_path
    File.join(AgraPrivate::Engine.paths["app/views"].existent, "organisations/#{current_organisation.slug}")
  end

  def streaming_csv(export)
    filename = "#{export.name}-#{Time.now.strftime("%Y%m%d")}.csv"
    if(export.total_rows < Queries::Exports::MAX_ROWS)
      self.response.headers['Content-Type'] = 'text/csv; charset=utf-8; header=present'
      self.response.headers['Content-Disposition'] = "attachment; filename=#{filename}"
      self.response.headers['Content-Transfer-Encoding'] = 'binary'
      self.response.headers['Last-Modified'] = Time.now.httpdate
      self.response_body = export.as_csv_stream
    else
      csv_report = CsvReport.new(name: filename, export: export, exported_by: current_user)
      csv_report.save!
      Jobs::GenerateExportCSVJob.perform_async(csv_report.id)
      flash[:notice] = t('controllers.application.csv_generation_in_progress')
      flash.keep
      redirect_to request.env['HTTP_REFERER']
    end
  end

  def has_facebook_user_agent?
    (request.env['HTTP_USER_AGENT'] =~ /facebookexternalhit/)
  end

  def render_not_found
    render 'errors/not_found', status: :not_found
  end

  def organisation_not_found
    render 'errors/organisation_not_found', layout: false
  end
end