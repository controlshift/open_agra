require 'spec_helper'

describe Org::Efforts::LeadersController do
  include_context "setup_default_organisation"

  context "logged in" do
    before(:each) do
      @effort = create(:effort, organisation: @organisation)
      @location = create(:location)
      @target = create(:target, name: "target name", phone_number: "12345678", email: "test@abc.com", location: @location, organisation: @organisation)
      @petition = create(:petition, organisation: @organisation, target: @target, effort: @effort)
      @user = create(:org_admin, organisation: @organisation)
      sign_in @user
    end

    describe "show" do
      before(:each) { get :show, effort_id: @effort, id: @petition}

      specify { response.should be_success }
      specify { assigns(:user).should == @petition.user }

      it "should ignore petition's first leader for additional campaign admins" do
        another_admin = create(:user, organisation: @organisation)
        create(:campaign_admin, user: another_admin, petition: @petition, invitation_email: another_admin.email)

        get :show, effort_id: @effort, id: @petition
        assigns(:admins).should == [another_admin]
      end
    end

    describe "destroy" do
      before(:each) { delete :destroy, effort_id: @effort, id: @petition}

      specify { response.should be_redirect }
      specify { assigns(:petition).user.should be_nil }
    end
  end

end