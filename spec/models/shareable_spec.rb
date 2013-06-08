require 'spec_helper'

describe Shareable do
  it "should load a facebook share object" do
    petition = FactoryGirl.create(:petition)
    petition.facebook_share.should_not be_nil
    petition.facebook_share.title.should == petition.title
  end

  it "should choose one of the variants" do
    petition = FactoryGirl.create(:petition)
    FactoryGirl.create(:facebook_share_variant, petition: petition)
    FactoryGirl.create(:facebook_share_variant, petition: petition)
    petition.facebook_share_variants.any?.should be_true
    petition.facebook_share.should_not be_nil
    petition.facebook_share.title.should_not be_nil
  end
end