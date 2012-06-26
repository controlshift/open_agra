require 'spec_helper'

describe ApplicationService do
  subject { ApplicationService.new }

  describe "#current_object" do
    it "should allow set and get" do
      obj = mock()
      as = ApplicationService.new
      as.current_object= obj
      as.current_object.should == obj
    end
  end

  describe "#save" do
    it "should let you save an object" do
      obj = mock()
      obj.stub(:new_record?).and_return(true)
      obj.should_receive(:save)
      subject.save(obj)
    end

    it "should trigger create" do
      obj = mock()
      obj.stub(:new_record?).and_return(true)
      obj.stub(:save)

      subject.should_receive(:create)
      subject.save(obj)
    end


    it "should trigger update" do
      obj = mock()
      obj.stub(:new_record?).and_return(false)
      obj.stub(:save)

      subject.should_receive(:update)
      subject.save(obj)
    end
  end

  describe "#update_attributes" do
    it "should trigger update" do
      obj = mock()
      obj.should_receive(:assign_attributes).with( {:foo => 'bar'}).and_return(:true)
      obj.should_receive(:save)

      subject.update_attributes(obj, {:foo => 'bar'})
    end

  end
end