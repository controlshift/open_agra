# == Schema Information
#
# Table name: stories
#
#  id                 :integer         not null, primary key
#  title              :string(255)
#  content            :text
#  featured           :boolean
#  created_at         :datetime        not null
#  updated_at         :datetime        not null
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  organisation_id    :integer
#  link               :string(255)
#

require 'spec_helper'

describe Story do
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:content) }

  it { should allow_mass_assignment_of(:title) }
  it { should allow_mass_assignment_of(:content) }
  
  it { should allow_value("http://www.getup.gov.au").for(:link) }
  it { should allow_value("https://www.communityrun.org").for(:link) }
  it { should_not allow_value("ftp://www.random.com").for(:link) }
  it { should_not allow_value("missing.com").for(:link) }
  
  describe "#featured" do
    it "should retrieve featured stories" do
      story1 = Factory(:story, featured: true)
      story2 = Factory(:story, featured: false)
      story3 = Factory(:story, featured: true)
      
      Story.featured.should =~ [story1, story3]
    end
  end

  describe "max length of title and content" do
    it "should be not invalid if title and content all together exceed max length" do
     story = Factory.stub(:story)

     story.title.clear
     150.times {story.title << 'a'}
     story.content.clear
     51.times {story.content << 'b'}
     story.should_not be_valid

     story.title.clear
     50.times {story.title << 'a'}
     story.content.clear
     151.times {story.content << 'b'}
     story.should_not be_valid

     story.title.clear
     story.content.clear
     210.times {story.title << 'a'}
     story.should_not be_valid

     story.title.clear
     story.content.clear
     210.times {story.content << 'b'}
     story.should_not be_valid

     story.errors_on(:content).should == ['Total length of title and content is too long (maximum 200 characters).']
    end

    it "should not invalid if title and content all together within max length" do
      story = Factory.stub(:story)

      story.title.clear
      story.title << 'a'
      story.content.clear
      story.content << 'b'
      story.should be_valid

      story.title.clear
      50.times {story.title << 'a'}
      story.content.clear
      150.times {story.content << 'b'}
      story.should be_valid
    end
  end
  
  describe "attaching an image" do
    it { should validate_attachment_presence(:image) }
    it { should validate_attachment_content_type(:image).allowing('image/jpeg', 'image/png').rejecting('text/plain', 'text/xml') }

    it "copies specific paperclip errors to #image for SimpleForm integration" do
      story = Factory.stub(:story)
      story.errors.add(:image_content_type, "must be an image file")
      story.run_callbacks(:validation)
      story.errors[:image].should == ["must be an image file"]
    end

    it "removes unreadable paperclip errors from #image" do
      story = Factory.stub(:story)
      story.errors.add(:image, "/var/12sdfsdf.tmp no decode delegate found")
      story.run_callbacks(:validation)
      story.errors[:image].should == []
    end
  end
end
