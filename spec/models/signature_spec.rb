# == Schema Information
#
# Table name: signatures
#
#  id                       :integer         not null, primary key
#  petition_id              :integer
#  email                    :string(255)     not null
#  first_name               :string(255)
#  last_name                :string(255)
#  phone_number             :string(255)
#  postcode                 :string(255)
#  created_at               :datetime
#  join_organisation        :boolean
#  deleted_at               :datetime
#  token                    :string(255)
#  unsubscribe_at           :datetime
#  external_constituent_id  :string(255)
#  member_id                :integer
#  additional_fields        :hstore
#  cached_organisation_slug :string(255)
#  source                   :string(255)     default("")
#  join_group               :boolean
#  external_id              :string(255)
#  new_member               :boolean
#

require 'spec_helper'
require 'support/shared_examples/validates_postcode'


describe Signature do
  before(:each) do
    @signature = Signature.new
  end

  subject { @signature }

  it_behaves_like "validates postcode"
  it {should belong_to(:member)}

  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:postcode) }
  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
  
  it { should ensure_length_of(:first_name).is_at_most(50) }
  it { should ensure_length_of(:last_name).is_at_most(50) }
  it { should ensure_length_of(:phone_number).is_at_most(30) }
  
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

  it "should allow several variants for how to express a phone number" do
    should allow_value('(202) 630-6288').for(:phone_number)
    should allow_value('  (202) 630-6288').for(:phone_number)
    should allow_value('(202)630-6288').for(:phone_number)
    should allow_value('2026306288').for(:phone_number)
    should allow_value('202-630-6288').for(:phone_number)
  end

  it "should shorten the akid and source fields" do
    ipsum = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip
            ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu
            fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt
            mollit anim id est laborum"
    signature = Factory.build(:signature, source: ipsum, akid: ipsum)
    signature.valid?
    signature.akid.length.should == 253
    signature.source.length.should == 253
  end

  describe "postcodes" do
    it { should allow_value('02052').for(:postcode) }
    describe "in india" do
      before(:each) { subject.stub(:country).and_return 'IN' }
      it { should allow_value('').for(:postcode) }
    end
    it { should allow_value('02052-1234').for(:postcode) }
    it { should_not allow_value('fooooooo bar bar gooooof   fooooof fofofofoosd').for(:postcode) }
  end

  describe "email addresses" do
    it { should allow_value('george@washington.com').for(:email) }
    it { should allow_value('george@ul.we.you.us').for(:email) }
    it { should_not allow_value('fooooooo bar bar gooooof   fooooof fofofofoosd fooooooo bar bar gooooof   fooooof fofofofoosd fooooooo bar bar gooooof   fooooof fofofofoosd fooooooo bar bar gooooof   fooooof fofofofoosd').for(:email) }
  end

  it "should not allow a non-digit word for phone number" do
    should_not allow_value('foo bar').for(:phone_number)
  end

  it "should allow a blank phone number" do
    should allow_value('').for(:phone_number)
  end

  it "should not allow a very short phone number" do
    should_not allow_value('999').for(:phone_number)
  end

  context "with a petition" do
    include_context "setup_stubbed_petition"

    it "should reject duplicate emails in different case for the same petition" do
      first_sig = Factory.build(:signature, email: "ANemail@email.com", postcode: '3245', petition: @petition)
      second_sig = Factory.build(:signature, email: "ANEMAIL@EMAIL.COM", postcode: '3245', petition: @petition)
      first_sig.save.should be_true
      second_sig.save.should be_false
      second_sig.errors[:email].should == ['has already signed']
    end
  end

  describe "#strip_attributes" do
    include_context "setup_stubbed_petition"

    it "should strip attributes" do
      signature = Factory.build(:signature, email: "  email@email.com ", first_name: " Huan Huan ", last_name: " Huang ",
                     phone_number: " 123456 ", postcode: " 1234 ", petition: @petition)
      signature.valid?
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
      Signature.new(first_name: "Fredo").first_name_or_friend.should == "Fredo"
    end

    it "should return Friend if no first name" do
      Signature.new.first_name_or_friend.should == "Friend"
    end
  end

  describe "deletion" do
    context "two signatures, one deleted" do
      include_context "setup_stubbed_petition"

      before(:each) do
        @present = Factory(:signature, :petition => @petition)
        @deleted = Factory(:signature, :petition => @petition, :deleted_at => Time.now)
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

    context "a petition" do
      include_context 'setup_stubbed_petition'

      it "should have token generated after save" do
        signature = Factory.build(:signature, petition: petition)
        signature.token.should be_nil
        signature.save!
        signature.token.should_not be_nil
      end
    end
  end
  
  describe "#subscribed" do
    include_context 'setup_stubbed_petition'

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

  describe "#employees" do
    include_context 'setup_stubbed_petition'

    it "should return signatures where is_employee is true" do
      Factory(:signature, petition: petition, join_organisation: true, additional_fields: {"is_employee" => "1"})
      Factory(:signature, petition: petition, unsubscribe_at: Time.now, join_organisation: true, additional_fields: {"is_employee" => "0"})
      Factory(:signature, petition: petition, unsubscribe_at: Time.now, join_organisation: true, additional_fields: {"is_employee" => "1"})
      
      Signature.employees.count.should == 2
      Signature.employees.each do |s|
        s.additional_fields["is_employee"].should == "1"
      end
    end
  end
  
  describe "#since" do
    include_context 'setup_stubbed_petition'
    
    before :each do
      @signature1 = Factory(:signature, created_at: 10.days.ago, petition: petition)
      @signature2 = Factory(:signature, created_at: 2.days.ago, petition: petition)
    end
    
    it "should get signatures since date" do
      signatures = petition.signatures.since(7.days.ago)
      signatures.should =~ [@signature2]
    end
  end

  describe "lookup" do
    include_context 'setup_stubbed_petition'

    before(:each) do
      @signature = Factory(:signature, petition: petition)
    end

    it "should allow lookups by email" do
      Signature.lookup(@signature.email, petition).should == @signature
    end

    it "should return nil when it does not exist" do
      Signature.lookup('george@washington.com', petition).should == nil
    end

    it "should be case insensitive" do
      Signature.lookup(@signature.email.upcase, petition).should == @signature
    end
  end

  describe "members" do
    include_context 'setup_stubbed_petition'

    it "should create a member when created" do
      signature = Signature.new(email: "george@washington.com", first_name: "George", last_name: "Washington", postcode: "11238", phone_number: "555-555-5555")
      signature.petition = petition
      signature.save
      signature.member.should_not be_nil
      signature.member.email.should == "george@washington.com"
    end

    it "should associate with an existing member" do
      member = Member.create(email: "george@washington.com", organisation: @organisation)
      signature = Signature.new(email: "george@washington.com", first_name: "George", last_name: "Washington", postcode: "11238", phone_number: "555-555-5555")
      signature.petition = petition
      signature.save

      member.reload
      member.signatures.should_not be_empty
      signature.member.should_not be_nil
    end
  end

  describe "country" do
    before(:each) do
      @organisation = FactoryGirl.build_stubbed(:organisation, country: 'US')
      @user = FactoryGirl.build_stubbed(:user)
      @petition = FactoryGirl.build_stubbed(:petition, organisation: @organisation, user: @user)
      @signature = Signature.new
      @signature.petition = @petition
    end

    it "should have a country" do
      @signature.country.should == 'US'
    end
  end
end
