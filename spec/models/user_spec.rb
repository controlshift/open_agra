# == Schema Information
#
# Table name: users
#
#  id                       :integer         not null, primary key
#  email                    :string(255)     default(""), not null
#  encrypted_password       :string(128)     default(""), not null
#  reset_password_token     :string(255)
#  reset_password_sent_at   :datetime
#  remember_created_at      :datetime
#  sign_in_count            :integer         default(0)
#  current_sign_in_at       :datetime
#  last_sign_in_at          :datetime
#  current_sign_in_ip       :string(255)
#  last_sign_in_ip          :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#  first_name               :string(255)
#  last_name                :string(255)
#  admin                    :boolean
#  phone_number             :string(255)
#  postcode                 :string(255)
#  join_organisation        :boolean
#  organisation_id          :integer         not null
#  org_admin                :boolean         default(FALSE)
#  confirmation_token       :string(255)
#  confirmed_at             :datetime
#  confirmation_sent_at     :datetime
#  opt_out_site_email       :boolean
#  facebook_id              :string(255)
#  external_constituent_id  :string(255)
#  member_id                :integer
#  additional_fields        :hstore
#  cached_organisation_slug :string(255)
#

require 'spec_helper'
require 'support/shared_examples/validates_postcode'

describe User do
  before(:each) do
    @user = User.new
  end

  subject{ @user }

  it_behaves_like "validates postcode"


  it { should have_many :petitions }
  it { should belong_to :organisation }
  it { should belong_to(:member)}

  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:password) }
  it { should validate_presence_of(:phone_number) }
  it { should validate_presence_of(:postcode) }
  it { should validate_acceptance_of(:agree_toc) }
  
  it { should ensure_length_of(:first_name).is_at_most(50) }
  it { should ensure_length_of(:last_name).is_at_most(50) }
  it { should ensure_length_of(:phone_number).is_at_most(50) }
  it { should ensure_length_of(:postcode).is_at_most(20) }
  
  it { should allow_mass_assignment_of(:first_name) }
  it { should allow_mass_assignment_of(:last_name) }
  it { should allow_mass_assignment_of(:email) }
  it { should allow_mass_assignment_of(:phone_number) }
  it { should allow_mass_assignment_of(:postcode) }
  it { should allow_mass_assignment_of(:opt_out_site_email) }

  describe "#find_by_email" do
    let(:user) {Factory(:user)}

    it "should find by email ignore case" do
      User.find_by_email(user.email).should == user
      User.find_by_email(user.email.capitalize).should == user
      User.find_by_email(user.email.swapcase).should == user
      User.find_by_email("ramdon@email.com").should_not == user
    end

    it "should find by email with strip" do
      User.find_by_email(" " + user.email + "   ").should == user
    end

    it "should handle email is nil" do
      User.find_by_email(nil).should be_nil
    end
  end

  describe "#find_by_email_and_organisation_id" do
    let(:organisation) {Factory(:organisation)}
    let(:user) {Factory(:user, organisation: organisation)}

    it "should find by email ignore case" do
      User.find_by_email_and_organisation_id(user.email, organisation).should == user
      User.find_by_email_and_organisation_id(user.email.capitalize, organisation).should == user
      User.find_by_email_and_organisation_id(user.email.swapcase, organisation).should == user
      User.find_by_email_and_organisation_id("ramdon@email.com", organisation).should_not == user
    end

    it "should find by email with strip" do
      User.find_by_email_and_organisation_id(" " + user.email + "   ", organisation).should == user
    end

    it "should handle email is nil" do
      User.find_by_email_and_organisation_id(nil, organisation).should be_nil
    end

  end


  describe "#strip_attributes" do
    it "should strip attributes" do
      user = Factory(:user, email: "  email@email.com ", first_name: " Huan Huan ", last_name: " Huang ",
                            phone_number: " 123456 ", postcode: " 1234 ")
      user.email.should == "email@email.com"
      user.first_name.should == "Huan Huan"
      user.last_name.should == "Huang"
      user.phone_number.should == "123456"
      user.postcode.should == "1234"
    end
  end
  
  it "should accept word characters for first name" do
    should allow_value('ABCDEFGHIJKLMNOPQRSTUVWXYZ').for(:first_name)
    should allow_value("abcdefghijklmnopqrstuvwxyz1234567890- '").for(:first_name)
  end

  it "should not accept symbols for first name" do
    should_not allow_value(',<.>/?;:"[{}]"~!@#$%^&*()_=+ ').for(:first_name)
  end
  
  it "should accept word characters for last name" do
    should allow_value('ABCDEFGHIJKLMNOPQRSTUVWXYZ').for(:last_name)
    should allow_value("abcdefghijklmnopqrstuvwxyz1234567890- '").for(:last_name)
  end
  
  it "should not accept symbols for last name" do
    should_not allow_value(',<.>/?;:"[{}]"~!@#$%^&*()_=+ ').for(:last_name)
  end

  it "should allow a some punctuation in names" do
    should allow_value("O'Malley Sr.").for(:last_name)
  end
  
  it "should accept validate phone number" do
    should allow_value('(+61) 123 456 789').for(:phone_number)
  end
  
  it "should not require confirmation" do
    subject.send(:confirmation_required?).should == false
  end

  it "should know if it is an admin?" do
    should respond_to(:admin?)
  end

  it "should know its full name" do
    @user.first_name = "Charlie"
    @user.last_name = "Brown"

    @user.full_name.should == "Charlie Brown"
  end

  it "should reject duplicate emails in different case for the same organisation" do
    org = Factory(:organisation)
    first_user = User.new(first_name: 'first', last_name: 'last', email: 'anemail@getup.org.au', phone_number: '12342', postcode: '4324', password: 'fdsawefds', agree_toc: "1")
    second_user = User.new(first_name: 'first', last_name: 'last', email: 'ANEMAIL@getup.org.au', phone_number: '12342', postcode: '4324', password: 'fdsawefds', agree_toc: "1")
    first_user.organisation = org
    second_user.organisation = org
    first_user.save.should be_true
    second_user.save.should be_false
    second_user.errors[:email].should_not be_empty
  end

  it "should index associated petitions on save" do
    organisation = Factory(:organisation)
    @petition = Factory(:petition, user: @user = Factory(:user, organisation: organisation), organisation: organisation)
    @petition.should_receive(:solr_index)
    @user.should_receive(:petitions).and_return([@petition])
    @user.update_attributes(first_name: 'Bob')
  end

  context "one person, multiple organisations" do
    before(:each) do
      @organisation = Factory(:organisation)
      @organisation_2 = Factory(:organisation)
      @user = Factory(:user, organisation: @organisation)
    end

    it "should find the right person while doing a warden lookup" do
      User.find_for_database_authentication(email: @user.email, organisation_id: @organisation.id).should == @user
    end

    describe "should not find the user, while looking in another organisation" do
      subject { User.find_for_database_authentication(email: @user.email, organisation_id: @organisation_2.id)}
      specify{ subject.should_not == @user }
      specify{ subject.should be_nil }
    end

    describe "multiple records for the same email address" do
      before(:each) do
        @new_user = Factory.build(:user, email: @user.email, organisation: @organisation_2)
      end

      it "should be valid" do
        @new_user.valid?.should be_true
      end

      context "when saved" do
        before(:each) do
          @new_user.save!
        end

        it "should find the new user, while looking in the other organisation" do
          User.find_for_database_authentication(email: @new_user.email, organisation_id: @organisation_2.id).should == @new_user
        end
      end
    end
  end

  describe "factory" do
    before(:each) do
      @user = Factory(:user)
    end

    it "should return a valid object" do
      @user.should be_valid
    end

    it "should allow for a second user in the same org" do
      user2 = Factory.build(:user, organisation: @user.organisation)
      user2.should be_valid
      user2.save
    end
  end

  describe "#manageable petitions" do
    before(:each) do
      @petition = Factory(:petition)
      @user = @petition.user
      @user.reload
    end

    it "should include the creator" do
      @user.manageable_petitions.should include(@petition)
    end

    describe "with campaign admins" do
      before(:each) do
        @petition_2 = Factory(:petition)
        Factory(:campaign_admin, petition: @petition_2, user: @user, invitation_email: @user.email)
      end

      it "should include both petitions" do
        @user.manageable_petitions.should include(@petition)
        @user.manageable_petitions.should include(@petition_2)
      end
    end
  end

  describe "#signature_fields" do
    it "should extract the fields that apply to a signature" do
      user = Factory.build(:user)
      fields = user.signature_attributes(Signature.new)
      fields.should_not == {}
      fields[:first_name].should == user.first_name
    end
  end
end
