require 'spec_helper'

describe Queries::Query do
  describe "#persisted?" do
    specify{ Queries::Query.new.persisted?.should be_false}
  end

  describe ".reflect_on_association" do
    specify{ Queries::Query.reflect_on_association(:foo).should be_nil }
  end

  describe "initialization" do
    class ExampleQuery < Queries::Query
      attr_accessor :foo
    end

    it "should allow the setting of foo" do
      eq = ExampleQuery.new(:foo => 'bar')
      eq.foo.should == 'bar'
    end
  end
end
