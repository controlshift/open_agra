require 'spec_helper'

describe Queries::Exports::SignaturesExport do
  context "instantiated" do
    subject { Queries::Exports::SignaturesExport.new  }

    it "should have signatures as a name" do
      subject.name.should == 'signatures'
    end
  end

  context "with a signature" do
    before(:each) do
      @organisation = Factory(:organisation)
      @petition = Factory.create(:petition, organisation: @organisation)
      Factory(:signature, petition: @petition)
    end

    subject { Queries::Exports::SignaturesExport.new(organisation: @organisation) }

    it "should export signatures" do
      subject.as_csv_stream.to_s.should_not == ""
    end

    it "should have a header_row" do
      subject.header_row.should == ["id", "petition_id", "email", "first_name", "last_name", "phone_number", "postcode", "created_at", "join_organisation", "deleted_at", "unsubscribe_at", "external_constituent_id", "member_id"]
    end

    context "as a magician" do
      before(:each) do
        @organisation.stub(:slug).and_return('rspec')
      end

      it "should have a magical header row" do
        subject.header_row.should == ["id", "petition_id", "email", "first_name", "last_name", "phone_number", "postcode", "created_at", "join_organisation", "deleted_at", "unsubscribe_at", "external_constituent_id", "member_id", "magician"]
      end
    end
  end
end