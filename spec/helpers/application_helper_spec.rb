require 'spec_helper'

describe ApplicationHelper do
  include Devise::TestHelpers

  describe "#cf" do
    it "should grab the text" do
      helper.stub(:current_organisation).and_return(organisation = mock())
      Content.should_receive(:content_for).with('slug', organisation).and_return('content text')
      helper.cf('slug').should == 'content text'
    end
  end

  describe "#sortable" do
    before :each do
      list = mock()
      list.stub(:sort_column).and_return('title')
      list.stub(:sort_direction).and_return('asc')

      helper.stub(:list).and_return(list)
    end

    it "should sort on the selected column" do
      helper.should_receive(:link_to).with('Admin Status', {sort: 'admin_status', direction: 'desc'}, {class: nil})
      helper.sortable(:admin_status)
    end

    it "should reverse sort on current sorted column" do
      helper.should_receive(:link_to).with('Title', {sort: 'title', direction: 'desc'}, {class: 'current asc'})
      helper.sortable(:title)
    end
  end

  describe "#join_label" do
    it "should use the combined label by default" do
      helper.stub(:current_organisation).and_return(organisation = mock())
      organisation.stub(:combined_name).and_return('name')
      organisation.stub(:join_label).and_return('')
      helper.join_label.should == 'Join name'
    end

    it "otherwise use the join label" do
      helper.stub(:current_organisation).and_return(organisation = mock())
      organisation.stub(:join_label).and_return('foo')
      helper.join_label.should == 'foo'
    end
  end

  describe '#ask_for_location?' do
    
    let(:organisation) { mock }
    let(:petition) { mock }
    let(:effort) { mock }
    
    before :each do
      helper.stub(:current_organisation).and_return(organisation)
    end

    it 'returns true if organisation requires it' do
      organisation.stub(:requires_location_for_campaign?).and_return(true)
      helper.ask_for_location?.should be_true
    end

    it 'returns true if a current petition is inside effort where location is required' do
      organisation.stub(:requires_location_for_campaign?).and_return(false)
      petition.stub(:effort).and_return(effort)
      effort.stub(:ask_for_location?).and_return(true)
      helper.instance_variable_set(:@petition, petition)
      helper.ask_for_location?.should be_true
    end

    it 'returns false if a current petition is not inside an effort and organisation does not requires it' do
      organisation.stub(:requires_location_for_campaign?).and_return(false)
      petition.stub(:effort).and_return(nil)
      helper.instance_variable_set(:@petition, petition)
      helper.ask_for_location?.should be_false
    end

    it 'returns false if a current organisation and effort do not require location' do
      organisation.stub(:requires_location_for_campaign?).and_return(false)
      petition.stub(:effort).and_return(effort)
      effort.stub(:ask_for_location?).and_return(false)
      helper.instance_variable_set(:@petition, petition)
      helper.ask_for_location?.should be_false
    end

  end

end