shared_context "setup_default_organisation" do
  before do
    @organisation = Factory(:organisation)
    controller.stub(:current_organisation) { @organisation }
  end
end