module OrganisationHelpers
  def current_organisation
    @current_organisation ||= Organisation.find_by_host(canonical_host) || raise("please run 'rake db:prepare_organisation'")
  end

  def canonical_host
    host = request.host
    mapping[host] || host
  end

  def mapping
    {'coworker.controlshiftlabs.com' => 'www.coworker.org'}
  end
end