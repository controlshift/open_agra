require 'spec_helper'

describe Geography do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:shape) }
  it { should validate_presence_of(:geographic_collection) }

  context "with a sample geography" do
    before(:each) do
      @collection = FactoryGirl.create(:geographic_collection)
      kml = File.read(Rails.root.join("spec/fixtures/geography.kml"))
      @geography = Geography.find(Geography.from_kml(kml, 'name', @collection)["id"])
    end

    it { should validate_uniqueness_of(:name).scoped_to(:geographic_collection_id) }

    it "should summarize points" do
      @geography.summarize_points(10).size.should == 11
    end

    it "should be a polygon" do
      @geography.type.should == :polygon
    end
  end
end
