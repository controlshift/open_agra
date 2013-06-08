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
  describe "#image_helpers" do
    it "should return image tag with title and alt text as specified in the entity" do
      entity = mock(title: 'My Title', errors: [], image_file_name: 'image.png')
      entity.should_receive(:image).and_return(mock(url: '/assets/image.png'))
      helper.image_content({entity: entity, style: :icon}).should == '<div class="petition-image"><img alt="My Title" src="/assets/image.png" title="My Title" /></div>'
    end  
    it "should return image tag with default title and alt text" do
      entity = mock(errors: [], image_file_name: 'image.png')
      entity.should_receive(:image).and_return(mock(url: '/assets/image.png'))
      helper.image_content({entity: entity, style: :icon, content_class: 'preview-image'}).should == '<div class="preview-image"><img alt="Picture" src="/assets/image.png" title="Picture" /></div>'
    end
    it "should return image tag with user profile image when user is not logged in through facebook" do
      entity = mock(errors: [], image_file_name: 'image.png', facebook_id: nil)
      entity.should_receive(:image).and_return(mock(url: '/assets/image.png'))
      helper.display_profile_image({entity: entity, style: :icon, content_class: 'profile-image'}).should == '<img alt="Picture" class="profile-image" src="/assets/image.png" />'
    end
    it "should return image tag with user profile image when it is present and user is logged in through facebook" do
      entity = mock(errors: [], image_file_name: 'image.png', facebook_id: '1234')
      entity.should_receive(:image).and_return(mock(url: '/assets/image.png'))
      helper.display_profile_image({entity: entity, style: :icon, content_class: 'profile-image'}).should == '<img alt="Picture" class="profile-image" src="/assets/image.png" />'
    end
    it "should return image tag with facebook profile image when user has no user profile image" do
      entity = mock(errors: [], image_file_name: nil, facebook_id: '1234')
      helper.display_profile_image({entity: entity, style: :icon, content_class: 'profile-image'}).should == '<img alt="Picture" class="profile-image" src="http://graph.facebook.com/1234/picture" />'
    end
  end
end