require 'spec_helper'

describe Petitions::ViewController do
  include_context "setup_default_organisation"

  describe "#show" do
    it "should raise exception if petition not found" do
      lambda { get :show, id: "unfound_petition" }.should raise_exception(ActiveRecord::RecordNotFound)
    end

    it "should autopopulate signature with current user info" do
      @user = Factory(:user, organisation: @organisation)
      sign_in @user
      petition = Factory(:petition)

      get :show, id: petition

      assigns(:signature).first_name.should == @user.first_name
      assigns(:signature).last_name.should == @user.last_name
      assigns(:signature).email.should == @user.email
      assigns(:signature).phone_number.should == @user.phone_number
      assigns(:signature).postcode.should == @user.postcode
    end

    shared_context "show as public" do
      it "should show appropriate petition" do
        get :show, id: @petition
        response.should render_template :show
      end

      it "should show an alert message if petition is cancelled" do
        @petition.update_attribute(:cancelled, true)
        get :show, id: @petition
        response.should redirect_to root_path
        flash[:alert].should == "We're sorry, this petition is not available."
      end

      it "should show an alert message if petition is not launched" do
        @petition.update_attribute(:launched, false)
        get :show, id: @petition
        response.should redirect_to root_path
        flash[:alert].should == "We're sorry, this petition is not available."
      end

      it "should show inappropriate page if petition is inappropriate" do
        @petition.update_attribute(:admin_status, :inappropriate)
        get :show, id: @petition
        response.should render_template :show_inappropriate
      end
    end

    context "is public user" do
      include_context "show as public"

      before :each do
        @user = Factory(:user)
        @petition = Factory(:petition, user: @user)
      end
    end

    context "is not petition owner" do
      include_context "show as public"

      before :each do
        @user = Factory(:user)
        @viewer = Factory(:user)
        @petition = Factory(:petition, user: @user)
        sign_in @viewer
      end
    end

    context "is org admin for other organisation" do
      include_context "show as public"

      before :each do
        @user = Factory(:user)
        @other_org_admin = Factory(:user, organisation: Factory(:organisation), org_admin: true)
        @petition = Factory(:petition, user: @user)
        sign_in @other_org_admin
      end
    end

    shared_context "show as admin or owner" do
      it "should show appropriate petition" do
        get :show, id: @petition
        response.should render_template :show
      end

      it "should show the petition even if the petition is cancelled" do
        @petition.update_attribute(:cancelled, true)
        get :show, id: @petition
        response.should render_template(:show)
        assigns(:petition).id.should == @petition.id
      end

      it "should show redirect to launching page if the petition is not launched" do
        @petition.update_attribute(:launched, false)
        get :show, id: @petition
        response.should redirect_to launch_petition_path(@petition)
        flash[:alert].should == "Petition must be launched before it can be managed."
      end

      it "should show even if petition is inappropriate" do
        @petition.update_attribute(:admin_status, :inappropriate)
        get :show, id: @petition
        response.should render_template :show
      end
    end

    context "is petition owner" do
      include_context "show as admin or owner"

      before :each do
        @user = Factory(:user)
        @petition = Factory(:petition, user: @user)
        sign_in @user
      end
    end

    context "is org admin" do
      include_context "show as admin or owner"

      before :each do
        @user = Factory(:user, organisation: @organisation)
        @org_admin = Factory(:user, organisation: @organisation, org_admin: true)
        @petition = Factory(:petition, user: @user, organisation: @organisation)
        sign_in @org_admin
      end
    end

    context "is admin" do
      include_context "show as admin or owner"

      before :each do
        @user = Factory(:user, organisation: @organisation)
        @admin = Factory(:user, organisation: @organisation, admin: true)
        @petition = Factory(:petition, user: @user, organisation: @organisation)
        sign_in @admin
      end
    end
  end

  describe "#show_alias" do
    it "should show petition by alias" do
      user = Factory(:user, organisation: @organisation)
      petition = Factory(:petition, user: user, alias: "abc")

      get :show_alias, id: "abc"
      
      response.should redirect_to petition_path(petition)
    end
  end
end