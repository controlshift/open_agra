require 'spec_helper'


describe LazyLoad do

  it "it should call the block while accessing an object" do
    object = LazyLoad.new do
      "hello world"
    end

    object.should == 'hello world'
  end
end