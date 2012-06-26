require 'spec_helper'

describe Admin::OrganisationsController do
  context "signed in as admin" do
    include_context "setup_default_organisation"
    
    before(:each) do
      sign_in Factory(:admin)
    end

    describe "#index" do
      before(:each) { get :index }

      it { should assign_to :organisations }
      it { should render_template :index }
    end

    describe "#edit" do
      before(:each) { get :edit, id: @organisation.id }
      specify { should assign_to :organisation }
      specify { should render_template :edit }
    end

    describe "#create" do
      before(:each) do
        @org_hash = Factory.attributes_for(:organisation)
      end

      it "should allow valid create" do
        post :create, organisation: @org_hash
        assigns[:organisation].persisted?.should be_true
        Organisation.last.name.should == @org_hash[:name]
        response.should redirect_to admin_organisations_path
        flash[:notice].should == "Organisation was created successfully"
      end

      it "should not allow invalid create" do
        post :create, organisation: @org_hash.merge(name: "")
        response.should render_template :new
      end

    end

    describe "#update" do
      it "should allow people to update names" do
        post :update, id: @organisation.id, organisation: {name: 'foo'}
        @organisation.reload
        @organisation.name.should == 'foo'
        response.should redirect_to admin_organisations_path
        flash[:notice].should == "Organisation was updated successfully"
      end

      it "should now allow invalid updates" do
        post :update, id: @organisation.id, organisation: {host: 'http://www.google.com/'}
        @organisation.host.should_not == "http://www.google.com/"
        response.should_not redirect_to admin_organisations_path
        response.should render_template :edit
      end

      it "should allow updates to uservoice_widget_link" do
        post :update, id: @organisation.id, organisation: {uservoice_widget_link: 'foo.uservoice.com'}
        @organisation.reload
        @organisation.uservoice_widget_link.should == 'foo.uservoice.com'
      end

    end
  end
end
