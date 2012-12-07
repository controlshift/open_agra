require 'spec_helper'

describe Groups::UnsubscribesController do

  context "with appropriate objects" do
    before(:each) do
      @organisation = Factory(:organisation)
      @group = Factory(:group, organisation: @organisation)
      @petition = Factory(:petition, group: @group, organisation: @organisation)
      @member = @petition.user.member
      @subscription = GroupSubscription.create(member: @member, group: @group)

      controller.stub(:current_organisation).and_return(@organisation)

    end

    describe "#show" do
      before(:each) { get :show, group_id: @group.slug, id: @subscription.token}
      it { should assign_to :unsubscribe }
    end

    describe "#create" do
      it "should unsubscribe" do
        post :update, group_id: @group.slug, id: @subscription.token, group_unsubscribe: {email: @member.email}
        should assign_to :unsubscribe
        assigns(:unsubscribe).subscription.unsubscribed_at.should_not be_nil
      end
    end
  end
end
