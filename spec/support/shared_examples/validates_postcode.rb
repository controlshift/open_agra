require 'spec_helper'

shared_examples_for "validates postcode" do
  describe "postcode validation" do
    context "in the US" do
      before(:each) do
        subject.stub(:country).and_return('US')
      end

      it "should allow an valid postcode" do
        should allow_value('02052').for(:postcode)
      end

      it "should not allow an invalid postcode" do
        should_not allow_value('foo').for(:postcode)
      end
    end

    context "no country" do
      before(:each) do
         subject.stub(:country).and_return(nil)
      end

      it "should allow any postcode" do
        should allow_value('foo').for(:postcode)
      end

      it "should not allow blank for postcode" do
        should_not allow_value('').for(:postcode)
      end
    end

    context "in GB" do
      before(:each) do
        subject.stub(:country).and_return('GB')
      end

      it "should allow a British code" do
        should allow_value("EC1A 1BB").for(:postcode)
      end
    end

    context "in India" do
      before(:each) do
        subject.stub(:country).and_return('IN')
      end

      it "should accept any string" do
        should allow_value('foo').for(:postcode)
      end

      it "should accept a blank" do
        should allow_value('').for(:postcode)
      end

    end
  end
end
