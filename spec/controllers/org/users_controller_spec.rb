require 'spec_helper'

describe Org::UsersController do
  include_context "setup_default_organisation"
  
  context "signed in as admin" do
    before(:each) do
      sign_in Factory(:org_admin, organisation: @organisation)
    end

    describe "#index" do
      before(:each) { get :index }

      it { should assign_to :users }
      it { should render_template :index }
      it { should_not redirect_to '/' }
    end

    describe "#email" do
      describe "looking up someone that exists" do
        before(:each) do
          @user = Factory(:user, organisation: @organisation)
          get :email, email: @user.email
        end

        it { should redirect_to edit_org_user_path(@user) }
      end

      describe "looking up someone that does not exist" do
        before(:each) do
          get :email, email: 'xxfoo@bar.com'
        end

        it { should redirect_to org_users_path }
      end

      describe "looking up someone from another organisation" do
        before(:each) do
          @user = Factory(:user)
          get :email, email: @user.email
        end

        it { should redirect_to org_users_path }
      end
    end

    context "an existing user" do
      before(:each) do
        @existing_user = Factory(:user, organisation: @organisation)
      end

      describe "#edit" do
        before(:each) { get :edit, id: @existing_user.id }
        specify { assign_to :user }
        it { should render_template 'admin/users/edit' }
      end

      describe "edit another organisations user" do
        before(:each) do
          @user = Factory(:user)
          get :edit, id: @user.id
        end

        it { should redirect_to '/' }
      end

      describe "#update" do

        it "should not allow people to be made global admins" do
          @existing_user.admin?.should be_false
          post :update, id: @existing_user.id, user: {admin: '1'}
          @existing_user.reload
          @existing_user.admin?.should be_false
        end

        it "should allow people to be made org admins" do
          @existing_user.org_admin?.should be_false
          post :update, id: @existing_user.id, user: {org_admin: '1'}
          @existing_user.reload
          @existing_user.org_admin?.should be_true
        end


        it "should now allow invalid updates" do
          post :update, id: @existing_user.id, user: {first_name: ''}
          @existing_user.should_not == ''
        end
      end
    end
  end
end
