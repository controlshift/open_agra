shared_context "a target with stubbed associations" do
  before(:each) do
    @organisation = FactoryGirl.build_stubbed(:organisation) if !defined?(@organisation)
    @location = FactoryGirl.build_stubbed(:location)
    @target = FactoryGirl.create(:target, name: "target name", location: @location, organisation: @organisation)
  end

  let(:target) { @target }
end