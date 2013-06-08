module Salesforce
  def self.initialize_client(params)
    client = Databasedotcom::Client.new(params.slice(:host, :client_id, :client_secret))
    client.authenticate(params.slice(:username, :password))
    client.sobject_module = Salesforce
    client.materialize("Contact")
    client.materialize("Campaign")
    client.materialize("CampaignMember")
    client
  end
end