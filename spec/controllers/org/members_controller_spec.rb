require 'spec_helper'

describe Org::MembersController do
  include_context "setup_default_organisation"

  context "signed in as admin" do
    before(:each) do
      sign_in Factory(:org_admin, organisation: @organisation)
    end

    describe "#index" do
      before(:each) { get :index }

      it { should assign_to :members }
    end

    describe "#email" do
      describe "looking up someone that exists" do
        before(:each) do
          @member = Factory(:member, organisation: @organisation)
          get :email, email: @member.email
        end

        it { should redirect_to org_member_path(@member) }
      end

      describe "looking up someone that does not exist" do
        before(:each) do
          get :email, email: 'xxfoo@bar.com'
        end

        it { should redirect_to org_members_path }
      end

      describe "looking up someone from another organisation" do
        before(:each) do
          @member = Factory(:member, organisation: Factory(:organisation))
          get :email, email: @member.email
        end

        it { should redirect_to org_members_path }
      end
    end

    context "an existing user" do
      before(:each) do
        @existing_user = Factory(:user, organisation: @organisation)
      end

      describe "#edit" do
        before(:each) { get :show, id: @existing_user.member.id }
        specify { assign_to :member }
      end
    end
  end
end
