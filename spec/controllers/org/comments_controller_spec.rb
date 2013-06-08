require 'spec_helper'

describe Org::CommentsController do
  context "#comments" do
    before :each do
      @organisation = Factory(:organisation)
      controller.stub(:current_organisation).and_return(@organisation)
      user = Factory(:org_admin, organisation: @organisation)
      @petition = Factory(:petition, organisation: @organisation)
      sign_in user
      @signature = Factory(:signature, petition: @petition)
    end

    describe "#index" do

      before :each do
        get :index
      end 

      context "no comments" do
        it "should return no comments" do
          response.should be_success
          assigns(:comments).should be_empty
        end
      end

      context "with a comment" do
        it "should return all comments" do
          comment = Factory(:comment, signature: @signature, text: "This is a test comment", flagged_at: Time.now)
          response.should be_success
          assigns(:comments).size.should == 1
          assigns(:comments).first.text.should == "This is a test comment"
        end
      end
    end

    describe "#approve" do
      it "should set the approved flag status as true" do
        comment = Factory(:comment, signature: @signature, text: "This is a test comment")
        put :approve, id: comment.id

        comment.reload

        response.should be_success
        comment.approved.should == true
      end
    end

    describe "#remove" do
      it "should set the approved flag status as false" do
        comment = Factory(:comment, signature: @signature, text: "This is a test comment")
        put :remove, id: comment.id

        comment.reload

        response.should be_success
        comment.approved.should == false
      end
    end
  end
end