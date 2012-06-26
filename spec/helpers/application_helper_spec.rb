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

end