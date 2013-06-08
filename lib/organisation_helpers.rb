require 'exceptions'

module OrganisationHelpers
  def current_organisation
    @current_organisation ||= Organisation.find_by_host(canonical_host) || raise(OrganisationNotFoundException.new)
  end

  def canonical_host
    host = request.host
    mapping[host] || host
  end

  def mapping
    {'coworker.controlshiftlabs.com'     => 'www.coworker.org',
    'simple-union.controlshiftlabs.com' => 'www.coworker.org',
    'you.leadnow.ca' => 'action.powervotebc.ca',
    '4mwb.localtunnel.com' => 'localhost'}
  end
end