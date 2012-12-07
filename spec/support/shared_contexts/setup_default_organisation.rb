shared_context "setup_default_organisation" do
  before do
    @organisation = Factory(:organisation, notification_url: "http://any.url.com")
    stub_request(:any, @organisation.notification_url)
    Organisation.stub(:find_by_host) { @organisation }
    controller.stub(:current_organisation) { @organisation }
  end
end

