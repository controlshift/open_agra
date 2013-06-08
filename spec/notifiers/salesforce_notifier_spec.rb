require 'spec_helper'

describe SalesforceNotifier do
  subject { SalesforceNotifier.new }
  describe ".present_attributes" do
    it "should not save fields that are blank" do
      signature = Factory.build(:signature, phone_number: nil)
      subject.send(:present_attributes, signature).keys.should == ["FirstName", "LastName", "MailingPostalCode", "Email" ]
    end
  end

  describe ".format_data" do
    let(:signature) { Factory.build(:signature, first_name: 'first', last_name: 'last', postcode: '12345', email: 'george@washington.com',  phone_number: nil) }

    context "with no custom fields" do
      it "should format user data" do
        subject.send(:format_data, signature).should == {"FirstName"=>"first", "LastName"=>"last", "MailingPostalCode"=>"12345", "Phone"=>nil, "Email"=>"george@washington.com"}
      end
    end

    context "with custom fields" do
      before(:each) do
        subject.organisation = Factory.build(:organisation, slug: 'rspec')
      end

      it "should format user data" do
        subject.send(:format_data, signature).should == {"FirstName"=>"first", "LastName"=>"last", "MailingPostalCode"=>"12345", "Phone"=>nil, "Email"=>"george@washington.com", "Data_Source__c" => "ControlShift"}
      end
    end
  end
end