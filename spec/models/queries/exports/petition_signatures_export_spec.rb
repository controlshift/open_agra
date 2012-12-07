describe Queries::Exports::PetitionSignaturesExport do
  context "a mock petition" do
    before(:each) do
      @petition = mock_model(Petition)
    end
    subject { Queries::Exports::PetitionSignaturesExport.new(petition: @petition) }

    it "should have generate some SQL" do
      subject.sql.should start_with("SELECT")
    end

  end
end