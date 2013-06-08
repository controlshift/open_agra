require 'spec_helper'

describe Queries::Exports::Export do
  context "a mock organisation" do
    let(:organisation){ mock_model(Organisation) }
    subject { Queries::Exports::Export.new(organisation: organisation) }
    context "stubbed sql" do
      before(:each) do
        subject.stub(:sql).and_return("SELECT * FROM petitions WHERE organisation_id = -22")
        subject.stub(:klass).and_return(Petition)
      end

      it "should append a limit and offset" do
        subject.sql_for_batch(100, 20).should == "SELECT * FROM petitions WHERE organisation_id = -22 AND petitions.id > 20 ORDER BY petitions.id LIMIT 100"
      end

      it "should return back the total count of rows" do
        subject.total_rows.should == 0
      end
    end

    context "rspec organisation" do
      before(:each) do
        org = mock(Organisation)
        org.stub(:slug).and_return('rspec')
        subject.stub(:organisation).and_return(org)
      end
      it "should have a magician boolean additional field" do
        subject.additional_field_keys.should == ["magician", "magician_kind"]
      end
    end

    context "ordinary signature" do
      it "should have a magician boolean additional field" do
        subject.additional_field_keys.should == []
      end
    end
  end
end


