require 'spec_helper'

describe Queries::Exports::MembersForGroupExport do
  context "appropriate objects" do
    before(:each) do
      @organisation = Factory(:organisation)
      @group = Factory(:group)

      petition = Factory(:petition, organisation: @organisation, group: @group)
      petition2 = Factory(:petition, organisation: @organisation, )
      @sign_no_join = Factory(:signature, email: "sign_no_join@domain.com", join_group: false, petition: petition)
      @sign_join = Factory(:signature, email: "sign_join@domain.com", first_name: 'George', last_name: 'Washington', join_group: true, join_organisation: true, petition: petition)
      @other_group = Factory(:signature, first_name: "othergroup", join_organisation: true, petition: petition2 )
    end

    describe ".people_as_csv" do
      subject { Queries::Exports::MembersForGroupExport.new(group_id: @group.id, organisation: @organisation)}

      before(:each) do
        @result = ""
        subject.as_csv_stream.each do |chunk|
          @result << chunk
        end
      end

      context "when parsed" do
        before(:each) do
          @parsed = CSV.parse(@result)
        end

        it "should include a header" do
          @parsed[0].should == ["id", "email", "first_name", "last_name", "phone_number", "postcode", "created_at"]
        end

        it "should include the appropriate signature" do
          @parsed[1].slice(1..3).should == ["sign_join@domain.com", "George", "Washington"]
        end
      end
    end
  end
end

