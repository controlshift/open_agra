# == Schema Information
#
# Table name: groups
#
#  id                 :integer         not null, primary key
#  organisation_id    :integer
#  title              :string(255)
#  slug               :string(255)
#  description        :text
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  created_at         :datetime        not null
#  updated_at         :datetime        not null
#

require 'spec_helper'

describe Group do
  context "a new group object" do
    before(:each) do
      @group = Group.new
    end

    subject { @group }
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:organisation) }
  end

end
