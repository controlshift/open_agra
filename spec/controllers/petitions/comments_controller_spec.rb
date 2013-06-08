require 'spec_helper'
describe Petitions::CommentsController do
  include_context "setup_default_organisation"
  before :each do
    @petition = Factory(:petition, :organisation => @organisation)
    @signature = Factory :signature, petition: @petition
  end
  describe '#create' do
    it "should be able to create a new comment for a signature without objectionable content" do
      post :create, :comment => {:text => 'this is a test comment'}, :petition_id => @petition.slug, :id => @signature.token

      response.should be_success
      Comment.all.size.should == 1
      Comment.all.first.text.should == 'this is a test comment'
      Comment.all.first.approved.should == nil
      Comment.all.first.up_count.should == 0
    end

    it "should create a comment for a signature and set approved flag as false when it contains objectionable content" do
      post :create, :comment => {:text => 'Oh shit! this is useless'}, :petition_id => @petition.slug, :id => @signature.token

      response.should be_success
      Comment.all.size.should == 1
      Comment.all.first.text.should == 'Oh shit! this is useless'
      Comment.all.first.approved.should == false
      Comment.all.first.flagged_at.should_not be_nil
    end

    it "should return error response if signature token is not present" do
      lambda {post :create, :comment => {:text => 'this is a test comment'}, :petition_id => @petition.slug}.should raise_exception
    end

    it "should render error if text is too small" do
      post :create, :comment => {:text => 'tiny'}, :petition_id => @petition.slug, :id => @signature.token
      response.should be_success
      Comment.all.size.should == 0
    end
  end

  context "with a comment" do
    let(:comment) { Factory(:comment, :text => "this is a test comment", :signature => @signature)}

    describe '#like' do
      it "should be able to increment the up_count" do
        put :like, :petition_id => @petition.slug, :id => comment.id

        comment.reload

        response.should be_success
        comment.up_count.should == 1
      end

      it "should raise error if the petition is suppressed and a comment is liked" do
        @petition.admin_status = :inappropriate
        @petition.admin_reason = "Some reason..."
        @petition.save

        put :like, :petition_id => @petition.slug, :id => comment.id

        response.should_not be_success
      end
    end

    describe "#show" do
      it "should render the page" do
        get :show, :petition_id => @petition.slug, :id => comment.id
        response.should be_success
      end

      context "a flagged comment" do
        before(:each) do
          comment.flagged_at = Time.now
          comment.save!
        end

        it "should return 404" do
          get :show, :petition_id => @petition.slug, :id => comment.id
          response.response_code.should == 404
        end
      end
    end
  end

  describe "#index" do
    it "should be able to return back the comments for a petition" do
      comment =Factory(:comment, :text => "this is a test comment", :signature => @signature)
      
      get :index, :petition_id => @petition.slug, format: 'js'
      response.should be_success
    end
    it "should return js" do
      get :index, {petition_id: @petition.slug, comment_start: "0", format: 'js'}
      response.should be_success
    end

    it "should return not found js if no comment exists" do
      get :index, {petition_id: @petition.slug, comment_start: "3", format: 'js'}
      response.should be_success
      response.body.should == "alert('No more comments!!');"
    end
  end
end