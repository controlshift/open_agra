shared_context "setup_petition" do
  before(:each) do
    @organisation = FactoryGirl.create(:organisation) if !defined?(@organisation)
    @user = FactoryGirl.create(:user, organisation: @organisation)
    @petition = FactoryGirl.create(:petition, organisation: @organisation, user: @user)
  end

  let(:petition) { @petition }
end

shared_context "setup_stubbed_petition" do
  before(:each) do
    @organisation = FactoryGirl.build_stubbed(:organisation) if !defined?(@organisation)
    @user = FactoryGirl.build_stubbed(:user, organisation: @organisation)
    @petition = FactoryGirl.build_stubbed(:petition, organisation: @organisation, user: @user, slug: 'slug')
  end

  let(:petition) { @petition }
end

