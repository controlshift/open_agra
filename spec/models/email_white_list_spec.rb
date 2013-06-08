# == Schema Information
#
# Table name: email_white_lists
#
#  id         :integer         not null, primary key
#  email      :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

require 'spec_helper'

describe EmailWhiteList do

  it { should validate_presence_of(:email) }
  it { should allow_mass_assignment_of(:email) }

  it "should allow different email addresses" do
    EmailWhiteList.create(email: "test@testmail.com")
    should validate_uniqueness_of(:email).case_insensitive
  end

  it "should be able to find by email case insensitive" do
    EmailWhiteList.create(email: "test@testmail.com")
    EmailWhiteList.find_by_email("TEST@testmail.com").should_not be_nil
    EmailWhiteList.find_by_email("TESTMETOO@testmail.com").should be_nil
  end
  describe "#find_by_email" do
    let(:email_white_list) {EmailWhiteList.create(email: "test@testmail.com")}

    it "should find by email ignore case" do
      EmailWhiteList.find_by_email(email_white_list.email).should == email_white_list
      EmailWhiteList.find_by_email(email_white_list.email.capitalize).should == email_white_list
      EmailWhiteList.find_by_email(email_white_list.email.swapcase).should == email_white_list
      EmailWhiteList.find_by_email("ramdon@email.com").should_not == email_white_list
    end

    it "should find by email with strip" do
      EmailWhiteList.find_by_email(" " + email_white_list.email + "   ").should == email_white_list
    end

    it "should handle email is nil" do
      EmailWhiteList.find_by_email(nil).should be_nil
    end
  end

  describe "#strip_attributes" do
    it "should strip attributes" do
      email_white_list = EmailWhiteList.create(email: " test@testmail.com ")
      email_white_list.email.should == "test@testmail.com"
    end
  end
end
