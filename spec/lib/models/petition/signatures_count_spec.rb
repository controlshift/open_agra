require "spec_helper"

describe "Petition::SignaturesCount" do
  context "petitions and signatures" do
    before(:each) do
      @organisation = Factory(:organisation)
      @user = Factory(:user, organisation: @organisation)
      @petition1 = Factory(:petition, organisation: @organisation, user: @user)
      @petition2 = Factory(:petition, organisation: @organisation, user: @user)

      Factory(:signature, petition: @petition1)
    end

    it "should include signatures count" do
      petitions = Petition.where(id: [@petition1.id, @petition2.id]).includes_signatures_count
      petitions.first.signatures_count.should == 1
      petitions.last.signatures_count.should == 0
    end

    it "should join and include signatures count" do
      petitions = Petition.where(id: [@petition1.id, @petition2.id]).order("id").join_and_includes_signatures_count
      petitions.first.signatures_count.to_i.should == 1
      petitions.last.signatures_count.to_i.should == 0
    end
  end
end