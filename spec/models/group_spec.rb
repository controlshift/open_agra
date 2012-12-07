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

  describe "#subscribed_signatures" do
    it "should return subscribed signatures of petitions within a group" do
      group = create(:group)
      petition = create(:petition, group: group)
      signature = create(:signature, petition: petition, join_organisation: true)
      unsubscribed_signature = create(:signature, petition: petition, unsubscribe_at: "2012-10-19 02:34:16", join_organisation: true)

      group.subscribed_signatures.should == [signature]
    end

    it "should ignore duplicated signatures among petitions" do
      group = create(:group)
      petition = create(:petition, group: group)
      another_petition = create(:petition, group: group)
      signature = create(:signature, petition: petition, join_organisation: true, email: "abc@abc.com")
      duplicated_signature = create(:signature, petition: another_petition, join_organisation: true, email: "abc@abc.com")

      group.subscribed_signatures.count.should == 1
    end
  end

end
