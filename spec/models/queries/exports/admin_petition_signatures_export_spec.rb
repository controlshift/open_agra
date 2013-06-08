require 'spec_helper'

describe Queries::Exports::AdminPetitionSignaturesExport do
  context "a mock petition" do
    before(:each) do
      @petition = mock_model(Petition)
    end
    subject { Queries::Exports::AdminPetitionSignaturesExport.new(petition_id: @petition.id) }

    it "should have generate some SQL" do
      subject.sql.should start_with("SELECT")
    end
  end
  context "with a signature" do
    before(:each) do
      @organisation = Factory(:organisation)
      @petition = Factory.create(:petition, organisation: @organisation)
      Factory(:signature, petition: @petition)
    end

    subject { Queries::Exports::AdminPetitionSignaturesExport.new(organisation: @organisation, petition_id: @petition.id) }

    it "should export signatures" do
      subject.as_csv_stream.to_s.should_not == ""
      subject.total_rows.should == 1
    end

    it "should have a header_row" do
      subject.header_row.should == ["id", "petition_id", "email", "first_name", "last_name", "phone_number", "postcode", "created_at", "join_organisation", "deleted_at", "unsubscribe_at", "external_constituent_id", "member_id", "source", "join_group", "external_id", "new_member", "comment"]
    end
  end
end