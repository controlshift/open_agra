require 'spec_helper'

describe Petitions::ViewController do
  include_context "setup_default_organisation"

  describe "#show" do
    it "should raise exception if petition not found" do
      lambda { get :show, id: "unfound_petition" }.should raise_exception(ActiveRecord::RecordNotFound)
    end

    context "well stubbed signed in user" do
      before(:each) do
        @user = Factory.build(:user, organisation: @organisation)
        controller.stub(:current_user).and_return(@user)
        @petition = Factory(:petition, organisation: @organisation)
      end

      it "should autopopulate signature with current user info" do
        get :show, id: @petition

        assigns(:signature).first_name.should == @user.first_name
        assigns(:signature).last_name.should == @user.last_name
        assigns(:signature).email.should == @user.email
        assigns(:signature).phone_number.should == @user.phone_number
        assigns(:signature).postcode.should == @user.postcode
      end
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


    context "without a leader" do
      include_context "show as public"

      before :each do
        @petition = Factory(:petition_without_leader, organisation: @organisation)
      end
    end

    context "is public user" do
      include_context "show as public"

      before :each do
        @user = Factory(:user, organisation: @organisation)
        @petition = Factory(:petition, user: @user, organisation: @organisation)
      end
    end

    context "is not petition owner" do
      include_context "show as public"

      before :each do
        @user = Factory(:user, organisation: @organisation )
        @viewer = Factory(:user, organisation: @organisation)
        @petition = Factory(:petition, user: @user, organisation: @organisation)
        sign_in @viewer
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
        @user = Factory(:user, organisation: @organisation)
        @petition = Factory(:petition, user: @user, organisation: @organisation)
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
      petition = Factory(:petition, user: user, alias: "abc", organisation: @organisation)

      get :show_alias, id: "abc"
      
      response.should redirect_to petition_path(petition)
    end
  end

  describe "API Method" do
    before :each do
      @user = Factory(:user, organisation: @organisation)
      @effort = Factory(:effort, organisation: @organisation)
      @group = Factory(:group, organisation: @organisation)
      @petition = Factory(:petition, user: @user, alias: "abc", organisation: @organisation, effort: @effort, group: @group)
      @signature = Factory(:signature, petition: @petition)
      @category = Factory(:category, organisation: @organisation, petitions: [@petition])
    end

    shared_context "jsonp response" do
      it "should respond to jsonp requests" do
        get :show, {id: @petition, format: 'json', callback: 'foo'}
        response.body.should =~ /^foo/
      end
    end

    context "json response for valid petition" do
      include_context "jsonp response"

      it "should get petition details in json" do
        get :show, {id: @petition, format: 'json'}

        expected = {administered_at: @petition.administered_at,
                    alias: @petition.alias,
                    bsd_constituent_group_id: @petition.bsd_constituent_group_id,
                    created_at: @petition.created_at,
                    delivery_details: @petition.delivery_details,
                    id: @petition.id,
                    location_id: @petition.location_id,
                    slug: @petition.slug,
                    source: @petition.source,
                    title: @petition.title,
                    updated_at: @petition.updated_at,
                    what: @petition.what,
                    who: @petition.who,
                    why: @petition.why,
                    categories: [{name: @category.name, slug: @category.slug}],
                    goal: @petition.goal,
                    effort: @effort.slug,
                    group: @group.slug,
                    image_url: @petition.image.url,
                    creator_name: @user.full_name,
                    last_signed_at: @signature.created_at,
                    signature_count: 1}.to_json

        response.body.should == expected
      end
    end

    context "json response for cancelled petition" do
      before :each do
        @petition.update_attribute(:cancelled, true)
      end

      include_context "jsonp response"

      it "should return json with error message if petition is cancelled" do
        get :show, {id: @petition, format: 'json'}
        response.body.should == {error: true, msg: "We're sorry, this petition is not available."}.to_json
      end
    end

    context "json response for unlaunched petition" do
      before :each do
        @petition.update_attribute(:launched, false)
      end

      include_context "jsonp response"

      it "should return json with error message if petition is not launched" do
        get :show, {id: @petition, format: 'json'}
        response.body.should == {error: true, msg: "We're sorry, this petition is not available."}.to_json
      end
    end

    context "json response for inappropriate petition" do
      before :each do
        @petition.update_attribute(:admin_status, :inappropriate)
      end

      include_context "jsonp response"

      it "should return json with error message if petition is inappropriate" do
        get :show, {id: @petition, format: 'json'}
        response.body.should == {error: true, msg: "This Petition has been disabled because of inappropriate content"}.to_json
      end
    end
  end
end