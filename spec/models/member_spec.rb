# == Schema Information
#
# Table name: members
#
#  id              :integer         not null, primary key
#  email           :string(255)
#  organisation_id :integer
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#

require 'spec_helper'

describe Member do
  it { should have_one(:user)}
  it { should have_many(:signatures)}

  context "with a member" do
    before(:each) do
      @user = Factory(:user)
      @member = Member.create(email: @user.email, organisation: @user.organisation)
    end

    it "should allow lookups" do
      Member.lookup(@user.email, @user.organisation)
    end
  end
end
