require 'spec_helper'

describe Petitions::PetitionFlagsController do
  include_context "setup_default_organisation"
  
  describe "#create" do
    it "should raise exception if petition not found" do
      @user = Factory(:user)
      sign_in @user
      lambda {post :create, :petition_id =>"unfound_petition_id"}.should raise_exception(ActiveRecord::RecordNotFound)
    end

    it "should flag the petition" do
      @petition = Factory(:petition)
      lambda{post :create, {petition_id: @petition}}.should change(@petition.flags, :count).by(1)
    end

    it "should have the right notice if flag successfully" do
      @petition = Factory(:petition)
      post :create, {petition_id: @petition}
      flash[:notice].should == "The petition has been flagged."
    end

    it "should have the right alert if flag failed" do
      @petition = Factory(:petition)
      post :create, {petition_id: @petition}
      post :create, {petition_id: @petition}
      flash[:alert].should == "You have already flagged this petition."
    end

    context "notification" do
      before :each do
        @petition = Factory(:petition)
        Delayed::Job.count.should == 0
      end

      it "should notice the organisation if the petition has been flagged once" do
        post :create, {petition_id: @petition}
        Delayed::Job.count.should == 1
        success, failure = Delayed::Worker.new.work_off
        success.should == 1
        failure.should == 0
      end
      
      it "should notice the organisation if the petition has been flagged threshold th time" do
        pre_threshold = Agra::Application.config.flagged_petitions_threshold - 1
        pre_threshold.times { Factory(:petition_flag, petition: @petition) } 
        post :create, {petition_id: @petition}
        Delayed::Job.count.should == 1
        success, failure = Delayed::Worker.new.work_off
        success.should == 1
        failure.should == 0
      end

      it "should not notice the organisation if the petition has been flagged for the 4th time" do
        3.times { Factory(:petition_flag, petition: @petition) }
        post :create, {petition_id: @petition}
        Delayed::Job.count.should == 0
      end
    end
  end
end
