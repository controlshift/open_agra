require 'spec_helper'

describe Groups::ManageController do

  context "as a group admin" do
    before(:each) do
      @organisation = Factory(:organisation)
      @user = Factory(:user, organisation: @organisation)
      @group = Factory(:group, organisation: @organisation)
      controller.stub(:current_organisation).and_return(@organisation)
      Factory(:group_member, user: @user, group: @group, invitation_email: @user.email)
      sign_in @user
    end

    describe "#show" do
      before(:each) { get :show, group_id: @group.slug }
      it { should assign_to :group }
    end

    describe "#export" do
      it "should send_data to the user" do
        controller.should_receive(:send_data).and_return(:success)
        controller.stub(:render)
        get :export, group_id: @group.slug
      end
    end
  end
end
