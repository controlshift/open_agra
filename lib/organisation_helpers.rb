module OrganisationHelpers
  def current_organisation
    @current_organisation ||= Organisation.find_by_host(request.host) || raise("please run 'rake db:prepare_organisation'")
  end
end