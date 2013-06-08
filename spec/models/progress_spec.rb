require 'spec_helper'

describe Progress do
  describe "#goal" do
    it "should return goal of an effort" do
      effort = FactoryGirl.create(:effort)

      effort.stub(:cached_signatures_size).and_return(99)
      effort.goal.should == 100

      effort.stub(:cached_signatures_size).and_return(100)
      effort.goal.should == 200

      effort.stub(:cached_signatures_size).and_return(101)
      effort.goal.should == 200

      effort.stub(:cached_signatures_size).and_return(850)
      effort.goal.should == 1000

      effort.stub(:cached_signatures_size).and_return(1001)
      effort.goal.should == 2000
    end

    context "with petition" do
      include_context "setup_stubbed_petition"

      it "should return goal of a petition" do
        petition.stub(:cached_signatures_size).and_return(99)
        petition.goal.should == 100

        petition.stub(:cached_signatures_size).and_return(10001)
        petition.goal.should == 15000

        petition.stub(:cached_signatures_size).and_return(50001)
        petition.goal.should == 75000

        petition.stub(:cached_signatures_size).and_return(100000)
        petition.goal.should == 200000
      end
    end
  end

  describe "#cached_signatures_size" do
    it "should delegate to #signatures_size" do
      effort = FactoryGirl.create(:effort)
      effort.stub(:signatures_size).and_return(99)
      effort.cached_signatures_size.should == 99
    end
  end

  describe "#cached_comments_size" do 
    include_context "setup_stubbed_petition"

    it "should delegate to #comments_size" do
      petition.stub(:comments_size).and_return(2)
      petition.cached_comments_size.should == 2
    end
  end
end