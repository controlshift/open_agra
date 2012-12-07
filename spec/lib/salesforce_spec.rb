require 'spec_helper'

describe Salesforce do
  it "should setup the object" do
    params = {host: 'host', client_id: 'client_id', client_secret: 'client_secret', username: 'username', password: 'password'}
    client = mock()
    client.should_receive(:authenticate).with({username: 'username', password: 'password'})
    client.stub(:sobject_module=)
    client.stub(:materialize)
    Databasedotcom::Client.should_receive(:new).with({host: 'host', client_id: 'client_id', client_secret: 'client_secret'}).and_return(client)
    Salesforce.initialize_client(params)
  end
end