require 'spec_helper'

describe Org::Groups::PetitionsController do
  include_context "setup_default_organisation"

  context "signed in with a petition" do
    before(:each) do
      @petition = Factory(:petition, organisation: @organisation)
      @group = Factory(:group, organisation: @organisation)
      @user = Factory(:org_admin, organisation: @organisation)
      sign_in @user
    end

    it "should find the petition" do
      get :check, group_id: @group.slug,  id: @petition.slug
      response.should be_success
      JSON.parse(response.body).should == {"slug" => @petition.slug, "title" => @petition.title}
    end

    it "should not find a petition that does not exist" do
      get :check, group_id: @group.slug,  id:'foo'
      response.code.should == "406"
      JSON.parse(response.body).should == {"message" => "No petition found"}
    end

    it "should allow moves" do
      post :move, group_id: @group.slug,  id: @petition.slug
      assigns(:petition).group.should == @group
      response.should be_success
      JSON.parse(response.body).should == {"slug" => @petition.slug, "title" => @petition.title}
    end
  end
end