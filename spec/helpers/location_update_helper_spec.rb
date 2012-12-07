require 'spec_helper'

describe LocationUpdateHelper do

  it "should return true and assign location id if location is valid" do
    attributes = {}
    location = Factory(:location)
    Location.should_receive(:find_or_create_by_query).with(location.attributes[:query], location.attributes).and_return(location)

    helper.update_location(location.attributes, attributes).should == true
    attributes[:location_id].should == location.id
  end

  it "should return false and assign location id if location is invalid" do
    attributes = {}
    location = Factory(:location)
    Location.should_receive(:find_or_create_by_query).with(location.attributes[:query], location.attributes).and_return(location)
    location.stub(:valid?).and_return(false)

    helper.update_location(location.attributes, attributes).should == false
    attributes[:location_id].should == location.id
  end

  it "should return true and don't assign location id if location is not present" do
    attributes = {}
    helper.update_location({}, attributes).should == true
    attributes[:location_id].should == nil
  end

  it "should return true and don't assign location id if location latitude is not present" do
    attributes = {}
    helper.update_location("{'query': 'test'}".to_json, attributes).should == true
    attributes[:location_id].should == nil
  end

end
