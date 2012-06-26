# == Schema Information
#
# Table name: signatures
#
#  id                :integer         not null, primary key
#  petition_id       :integer
#  email             :string(255)     not null
#  first_name        :string(255)
#  last_name         :string(255)
#  phone_number      :string(255)
#  postcode          :string(255)
#  created_at        :datetime
#  join_organisation :boolean
#  deleted_at        :datetime
#  token             :string(255)
#  unsubscribe_at    :datetime
#

require 'spec_helper'

describe Signature do
  before(:each) do
    @signature = Signature.new
  end

  subject { @signature }
  
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:postcode) }
  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
  
  it { should ensure_length_of(:first_name).is_at_most(50) }
  it { should ensure_length_of(:last_name).is_at_most(50) }
  it { should ensure_length_of(:phone_number).is_at_most(50) }
  
  it { should allow_mass_assignment_of(:first_name) }
  it { should allow_mass_assignment_of(:last_name) }
  it { should allow_mass_assignment_of(:email) }
  it { should allow_mass_assignment_of(:phone_number) }
  it { should allow_mass_assignment_of(:postcode) }
  it { should allow_mass_assignment_of(:join_organisation) }
  
  it "should accept word characters for first name and last name" do
    should allow_value('ABCDEFGHIJKLMNOPQRSTUVWXYZ').for(:first_name)
    should allow_value("abcdefghijklmnopqrstuvwxyz1234567890- '").for(:first_name)
    should allow_value('ABCDEFGHIJKLMNOPQRSTUVWXYZ').for(:last_name)
    should allow_value("abcdefghijklmnopqrstuvwxyz1234567890- '").for(:last_name)
  end
  
  it "should not accept symbols for first name and last name" do
    should_not allow_value(',<.>/?;:"[{}]"~!@#$%^&*()_=+ ').for(:first_name)
    should_not allow_value(',<.>/?;:"[{}]"~!@#$%^&*()_=+ ').for(:last_name)
  end
  
  it "should accept validate phone number" do
    should allow_value('(+61) 123 456 789').for(:phone_number)
  end

  it "should allow an american phone number" do
    should allow_value('(518) 207-6768').for(:phone_number)
  end

  it "should reject duplicate emails in different case for the same petition" do
    petition = Factory(:petition)
    first_sig = Factory.build(:signature, email: "ANemail@email.com", postcode: '3245', petition: petition)
    second_sig = Factory.build(:signature, email: "ANEMAIL@EMAIL.COM", postcode: '3245', petition: petition)
    first_sig.save.should be_true
    second_sig.save.should be_false
    second_sig.errors[:email].should == ['has already signed']
  end

  it "should not reject duplicate emails for different petitions" do
    Factory(:signature, email: 'email@email.com', petition: Factory.stub(:petition))
    another_signature = Factory.stub(:signature, email: 'email@email.com', petition: Factory.stub(:petition))
    another_signature.should be_valid
  end

  describe "#strip_attributes" do
    it "should strip attributes" do
      signature = Factory(:signature, email: "  email@email.com ", first_name: " Huan Huan ", last_name: " Huang ",
                     phone_number: " 123456 ", postcode: " 1234 ", petition: Factory(:petition))
      signature.email.should == "email@email.com"
      signature.first_name.should == "Huan Huan"
      signature.last_name.should == "Huang"
      signature.phone_number.should == "123456"
      signature.postcode.should == "1234"
    end
  end

  describe "#full_name" do
    specify { Signature.new(first_name: "Charlie", last_name: "Brown").full_name.should == "Charlie Brown" }
    specify { Signature.new(first_name: "Charlie", last_name: "Brown").full_name_with_mask.should == "Charlie B." }
    specify { Signature.new(first_name: "Charlie").full_name.should == "Charlie" }
    specify { Signature.new(last_name: "Brown").full_name.should == "Brown" }
    specify { Signature.new.full_name.should == "Not provided" }
  end

  describe "#first_name_or_friend" do
    it "should take first name if present" do
      s = Signature.new(first_name: "Fredo")
      s.first_name_or_friend.should == "Fredo"
    end

    it "should return Friend if no first name" do
      Signature.new.first_name_or_friend.should == "Friend"
    end
  end

  describe "deletion" do
    context "two signatures, one deleted" do
      before(:each) do
        @present = Factory(:signature, :petition => Factory(:petition))
        @deleted = Factory(:signature, :petition => Factory(:petition), :deleted_at => Time.now)
      end

      it "should not find the deleted signature" do
        Signature.all.should == [@present]
      end
    end
  end

  describe "tokens" do
    it { should respond_to(:token) }
    specify { Signature.should  respond_to(:find_by_token!) }
    specify { Signature.should  respond_to(:find_by_token) }

    it "should have token generated after save" do
      signature = Factory.build(:signature, petition: Factory(:petition))
      signature.token.should be_nil
      signature.save!
      signature.token.should_not be_nil
    end
  end
  
  describe "#subscribed" do
    let(:petition) { Factory(:petition) }

    before :each do
     Factory(:signature, petition: petition, join_organisation: true)
    end

    it "should exclude unsubscribed signatures" do
     Factory(:signature, petition: petition, unsubscribe_at: Time.now, join_organisation: true)
      
      Signature.subscribed.count.should == 1
      Signature.subscribed.each do |s|
        s.unsubscribe_at.should be_nil
      end
    end

    it "should exclude deleted signatures" do
      Factory(:signature, petition: petition, deleted_at: Time.now, join_organisation: true)

      Signature.subscribed.count.should == 1
      Signature.subscribed.each do |s|
        s.deleted_at.should be_nil
      end
    end

    it "should exclude signatures who have not joined" do
      Factory(:signature, petition: petition, join_organisation: false)

      Signature.subscribed.count.should == 1
      Signature.subscribed.each do |s|
        s.join_organisation.should be_true
      end
    end
  end
  
  describe "#since" do
    let(:petition) { Factory(:petition) }
    
    before :each do
      @signature1 = Factory(:signature, created_at: Time.now - 10.day, petition: petition)
      @signature2 = Factory(:signature, created_at: Time.now - 6.day, petition: petition)
      @signature3 = Factory(:signature, created_at: Time.now - 2.day, petition: petition)
    end
    
    it "should get signatures since date" do
      signatures = petition.signatures.since(Time.now - 7.day)
      signatures.count.should == 2
      signatures.should =~ [@signature2, @signature3]
    end
  end

  describe "caching" do

  end
end
