require 'spec_helper'

describe GroupsController do
  before(:each) do
    @organisation = Factory(:organisation)
    @user = Factory(:user, organisation: @organisation)
    @group = Factory(:group, organisation: @organisation)
    controller.stub(:current_organisation).and_return(@organisation)
  end

  describe "#show" do
    before(:each) do
      get :show, id: @group
    end

    it { should assign_to :group }
    it { should assign_to :petitions }
    it { should render_template :show }
  end

end