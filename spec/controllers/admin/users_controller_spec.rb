require 'spec_helper'

describe Admin::UsersController do
  include_context "setup_default_organisation"
  
  context "signed in as admin" do
    before(:each) do
      sign_in Factory(:admin)
    end

    describe "#index" do
      before(:each) { get :index }

      it { should assign_to :users }
      it { should render_template :index }
    end

    describe "#email" do
      context "looking up someone that exists" do
        before(:each) do
          @user = Factory(:user)
          get :email, :email => @user.email
        end

        it { should redirect_to edit_admin_user_path(@user) }
      end

      context "looking up someone that does not exist" do
        before(:each) do
          @user = Factory(:user)
          get :email, :email => 'foo@bar.com'
        end

        it { should redirect_to admin_users_path }
      end
    end

    context "an existing user" do
      before(:each) do
        @existing_user = Factory(:user)
      end

      describe "#edit" do
        before(:each) { get :edit, id: @existing_user.id }
        specify { assign_to :user }
      end

      describe "#update" do
        it "should extract user attributes" do
          user_attrs = { 'first_name' => 'abc' }
          User.should_receive(:extract_accessible_attributes_symbol_hash_values).with(user_attrs)
          post :update, id: @existing_user.id, user: user_attrs
        end

        it "should allow people to be made admins" do
          @existing_user.admin?.should be_false
          post :update, id: @existing_user.id, user: {admin: '1'}
          @existing_user.reload
          @existing_user.admin?.should be_true
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
