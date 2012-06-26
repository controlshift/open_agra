require 'spec_helper'

describe Groups::PetitionsController do
  before(:each) do
    @organisation = Factory(:organisation)
    @user = Factory(:user, organisation: @organisation)
    @group = Factory(:group, organisation: @organisation)
    controller.stub(:current_organisation).and_return(@organisation)
  end

  describe "#new" do
    before(:each) do
      get :new, group_id: @group.slug
    end

    it { should assign_to :group }
    it { should assign_to :petition }
    it { should render_template :new}

    it "should make the petition have the right group" do
      assigns(:petition).group.should == @group
    end
  end

  context "as a group admin" do
    before(:each) do
      Factory(:group_member, user: @user, group: @group, invitation_email: @user.email)
      sign_in @user
    end

    context "with a few petition objects" do
      before(:each) do
        @petition = Factory(:petition, organisation: @organisation, group: @group)
        Factory(:signature, petition: @petition)

        @other_petition = Factory(:petition, organisation: @organisation)
        Factory(:signature, petition: @other_petition)
      end

      describe "#index" do
        before(:each) { get :index, group_id: @group.slug }

        it { should assign_to :list }
        it { should render_template :index }
        specify { assigns(:list).petitions.should include(@petition) }
        specify { assigns(:list).petitions.should_not include(@other_petition) }
      end

      describe "#hot" do
        before(:each) { get :hot, group_id: @group.slug }

        it { should assign_to :petitions }
        it { should render_template :hot }
        specify { assigns(:petitions).should include(@petition) }
        specify { assigns(:petitions).should_not include(@other_petition) }
      end
    end
  end
end
