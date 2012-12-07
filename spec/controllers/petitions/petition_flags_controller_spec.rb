require 'spec_helper'

describe Petitions::PetitionFlagsController do
  include_context "setup_default_organisation"
  
  describe "#create" do
    it "should raise exception if petition not found" do
      @user = Factory(:user, organisation: @organisation)
      sign_in @user
      lambda {post :create, :petition_id =>"unfound_petition_id"}.should raise_exception(ActiveRecord::RecordNotFound)
    end

    context "with a petition" do
      before(:each) do
        @petition = Factory(:petition, organisation: @organisation)
      end

      it "should flag the petition with reason" do
        lambda{post_create_flag}.should change(@petition.flags, :count).by(1)
      end

      it "should not flag the petition without reason" do
        lambda{post :create, {petition_id: @petition, reason: ""}}.should_not change(@petition.flags, :count)
      end

      it "should have the right notice if flag successfully" do
        post_create_flag
        flash[:notice].should == "The petition has been flagged."
      end

      it "should have the right alert if flag failed" do
        # TODO: should use factory
        post_create_flag
        post_create_flag
        flash[:alert].should == "You have already flagged this petition."
      end

      context "notification" do
        before :each do
          Delayed::Job.count.should == 0
        end

        it "should notice the organisation if the petition has been flagged once" do
          post_create_flag
          Delayed::Job.count.should == 1
          success, failure = Delayed::Worker.new.work_off
          success.should == 1
          failure.should == 0
        end

        it "should notice the organisation if the petition has been flagged threshold th time" do
          pre_threshold = Agra::Application.config.flagged_petitions_threshold - 1
          pre_threshold.times { Factory(:petition_flag, petition: @petition) }
          post_create_flag
          Delayed::Job.count.should == 1
          success, failure = Delayed::Worker.new.work_off
          success.should == 1
          failure.should == 0
        end

        it "should not notify the organisation if the petition has been flagged for the 4th time" do
          3.times { Factory(:petition_flag, petition: @petition) }
          post_create_flag
          Delayed::Job.count.should == 0
        end
      end
    end
  end
end

def post_create_flag
  post :create, {petition_id: @petition, reason: "some reason."}
end

