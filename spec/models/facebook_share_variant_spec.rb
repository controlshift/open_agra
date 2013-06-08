# == Schema Information
#
# Table name: facebook_share_variants
#
#  id                 :integer         not null, primary key
#  title              :string(255)
#  description        :text
#  type               :string(255)
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  petition_id        :integer
#  created_at         :datetime        not null
#  updated_at         :datetime        not null
#

require 'spec_helper'

describe FacebookShareVariant do
  context "before any experiments have been run" do
    it "should have have a nil split_alternative and zero counts" do
      petition = create(:petition)
      share = FacebookShareVariant.new(title: 'title')
      share.petition = petition
      share.save
      share.split_alternative.should_not be_nil
      share.participant_count.should == 0
      share.completed_count.should == 0
      share.rate.should == 0.0
    end
  end

  context "after an experiment run"  do
    let(:petition) { create(:petition) }

    before(:each) do
      @share_variant = FacebookShareVariant.new(title: 'title')
      @share_variant.petition = petition
      @share_variant.save
      petition.facebook_share_variants << @share_variant
      petition.save
      petition.facebook_share.choose
      petition.facebook_share.record!
    end

    it "should have have a split_alternative and a participant count" do
      @share_variant.split_alternative.should_not be_nil
      @share_variant.participant_count.should == 1
      @share_variant.completed_count.should == 0
      @share_variant.rate.should == 0.0
    end

    it "should have a rate of 1.0 after completion!" do
      petition.facebook_share.complete!
      @share_variant.participant_count.should == 1
      @share_variant.completed_count.should == 1
      @share_variant.rate.should == 1.0
    end
  end
end
