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

    it "should return goal of a petition" do
      petition = FactoryGirl.create(:petition)

      petition.stub(:cached_signatures_size).and_return(99)
      petition.goal.should == 100
    end
  end

  describe "#cached_signatures_size" do
    it "should delegate to #signatures_size" do
      effort = FactoryGirl.create(:effort)
      effort.stub(:signatures_size).and_return(99)
      effort.cached_signatures_size.should == 99
    end
  end
end