require 'spec_helper'

describe Queries::PeopleForGroup do
  context "appropriate objects" do
    before(:each) do
      @organisation = Factory(:organisation)
      @group = Factory(:group)

      petition = Factory(:petition, organisation: @organisation, group: @group)
      petition2 = Factory(:petition, organisation: @organisation, )
      @sign_no_join = Factory(:signature, email: "sign_no_join@domain.com", join_organisation: false, petition: petition)
      @sign_join = Factory(:signature, email: "sign_join@domain.com", first_name: 'George', last_name: 'Washington', join_organisation: true, petition: petition)
      @other_group = Factory(:signature, first_name: "othergroup", join_organisation: true, petition: petition2 )
    end

    describe ".people_as_csv" do
      subject { Queries::PeopleForGroup.new.people_as_csv(@group.id)}
      it "should include a header" do
        result = CSV.parse(subject)
        result[0].should == ["Email", "First Name", "Last Name", "Phone Number", "Postcode", "Created At"]
      end

      it "should include the appropriate signature" do
        result = CSV.parse(subject)
        result[1].slice(0..2).should == ["sign_join@domain.com", "George", "Washington"]
      end
    end
  end

end

