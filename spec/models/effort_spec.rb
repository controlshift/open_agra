# == Schema Information
#
# Table name: efforts
#
#  id                        :integer         not null, primary key
#  organisation_id           :integer
#  title                     :string(255)
#  slug                      :string(255)
#  description               :text
#  gutter_text               :text
#  title_help                :string(255)
#  title_label               :string(255)
#  title_default             :text
#  who_help                  :string(255)
#  who_label                 :string(255)
#  who_default               :text
#  what_help                 :string(255)
#  what_label                :string(255)
#  what_default              :text
#  why_help                  :string(255)
#  why_label                 :string(255)
#  why_default               :text
#  created_at                :datetime        not null
#  updated_at                :datetime        not null
#  image_file_name           :string(255)
#  image_content_type        :string(255)
#  image_file_size           :integer
#  image_updated_at          :datetime
#  thanks_for_creating_email :text
#  ask_for_location          :boolean
#

require 'spec_helper'

describe Effort do
  context 'a new effort object' do
    before(:each) do
      @effort = Effort.new(title: 'title')
    end

    subject { @effort }
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:organisation) }
  end

  describe 'validate length' do
    [:title, :slug, :title_label, :title_default, :who_label, :what_label, :why_label].each do |field|
      it { should ensure_length_of(field).is_at_most(255)}
    end
  end


  describe 'attaching an image' do
    it { should_not validate_attachment_presence(:image) }
    it { should validate_attachment_content_type(:image).allowing('image/png').rejecting('text/plain') }

    it 'copies specific paperclip errors to #image for SimpleForm integration' do
      effort = Factory.build(:effort)
      effort.errors.add(:image_content_type, 'must be an image file')
      effort.run_callbacks(:validation)
      effort.errors[:image].should == ['must be an image file']
    end

    it 'removes unreadable paperclip errors from #image' do
      effort = Factory.build(:effort)
      effort.errors.add(:image, '/var/12sdfsdf.tmp no decode delegate found')
      effort.run_callbacks(:validation)
      effort.errors[:image].should == []
    end
  end

  describe 'rendering content' do
    effort = Effort.new
    petition = Petition.new
    petition.title = 'A title'
    effort.thanks_for_creating_email = '{{ petition.title }}'
    effort.render(:thanks_for_creating_email, {'petition' => petition }).should == 'A title'
  end
end
