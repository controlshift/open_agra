require 'spec_helper'

describe Org::Efforts::PetitionsController do
  include_context "setup_default_organisation"

  context "signed in with a petition" do
    before(:each) do
      @effort = Factory(:effort, organisation: @organisation)
      @petition = Factory(:petition, organisation: @organisation, effort: @effort)
      @user = Factory(:org_admin, organisation: @organisation)
      sign_in @user
    end

    it "should find the petition" do
      get :check, effort_id: @effort.slug,  id: @petition.slug
      response.should be_success
      JSON.parse(response.body).should == {"slug" => @petition.slug, "title" => @petition.title}
    end

    it "should not find a petition that does not exist" do
      get :check, effort_id: @effort.slug,  id:'foo'
      response.code.should == "406"
      JSON.parse(response.body).should == {"message" => "No petition found"}
    end

    it "should allow moves" do
      post :move, effort_id: @effort.slug,  id: @petition.slug
      assigns(:petition).effort.should == @effort
      response.should be_success
      JSON.parse(response.body).should == {"slug" => @petition.slug, "title" => @petition.title}
    end
  end
end