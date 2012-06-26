require "spec_helper"

describe "Petition::PetitionFlagsCount" do
  let(:petition1) { Factory(:petition) }
  let(:petition2) { Factory(:petition) }
  
  before :each do
    Factory(:petition_flag, petition: petition1)
    Factory(:petition_flag, petition: petition1)
    Factory(:petition_flag, petition: petition2)
  end
  
  it "should include petition flags count" do
    petitions = Petition.where(id: [petition1.id, petition2.id]).includes_petition_flags_count
    petitions.first.petition_flags_count.should == 2
    petitions.last.petition_flags_count.should == 1
  end
  
  it "should join and include petition flags count" do
    petitions = Petition.where(id: [petition1.id, petition2.id]).order("id").join_and_includes_petition_flags_count
    petitions.first.petition_flags_count.to_i.should == 2
    petitions.last.petition_flags_count.to_i.should == 1
  end
end