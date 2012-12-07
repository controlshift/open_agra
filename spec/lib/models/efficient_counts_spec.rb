require "spec_helper"

describe "EfficientCounts" do
  describe "counting signatures" do
    let(:petition1) { Factory(:petition) }
    let(:petition2) { Factory(:petition) }

    before(:each) do
      Factory(:signature, petition: petition1)
    end

    it "should include signatures count" do
      expect { petition1.signatures_count }.to raise_error(NoMethodError)
      [petition1, petition2].includes_signatures_count
      petition1.signatures_count.should == 1
      petition2.signatures_count.should == 0
    end

    it "should join and include signatures count" do
      petitions = Petition.order('id ASC').join_and_includes_signatures_count
      petitions.first.id.should == petition1.id
      petitions.first.signatures_count.to_i.should == 1
    end
  end

  describe "counting flags" do
    let(:petition1) { Factory(:petition) }
    let(:petition2) { Factory(:petition) }

    before :each do
      Factory(:petition_flag, petition: petition1)
      Factory(:petition_flag, petition: petition1)
      Factory(:petition_flag, petition: petition2)
    end

    it "should include petition flags count" do
      [petition1, petition2].includes_petition_flags_count
      petition1.petition_flags_count.should == 2
      petition2.petition_flags_count.should == 1
    end

    it "should join and include petition flags count" do
      petitions = Petition.order("id").join_and_includes_petition_flags_count
      petitions.first.id.should == petition1.id
      petitions.first.petition_flags_count.to_i.should == 2
    end
  end
end