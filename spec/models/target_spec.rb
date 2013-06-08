# == Schema Information
#
# Table name: targets
#
#  id              :integer         not null, primary key
#  name            :string(255)
#  phone_number    :string(255)
#  email           :string(255)
#  location_id     :integer
#  organisation_id :integer
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#  slug            :string(255)
#

require 'spec_helper'

describe Target do
  describe Signature do
    before(:each) do
      @target = Target.new
    end

    subject { @target }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:organisation) }
    it { should ensure_length_of(:phone_number).is_at_most(50) }

    it "should validate presence of either geography or target" do
      subject.valid?
      subject.should have(1).errors_on(:base)

      subject.location = Location.new
      subject.valid?
      subject.should have(0).errors_on(:base)

      subject.location = nil
      subject.geography = Geography.new
      subject.valid?
      subject.should have(0).errors_on(:base)
    end

    it "should accept validate phone number" do
      should allow_value('(+61) 123 456 789').for(:phone_number)
    end

    it "should allow an american phone number" do
      should allow_value('(518) 207-6768').for(:phone_number)
    end

    it "should not allow invalid phone number" do
      should_not allow_value('abc(+86)1234321').for(:phone_number)
    end

    it "should not allow invalid email address" do
      should_not allow_value('abv @113com').for(:email)
    end

    context "an existing target" do
      include_context "a target with stubbed associations"

      it "should reject duplicate names" do
        duplicate_named_target = Factory.build(:target, name: target.name, location: @location, organisation: @organisation)
        duplicate_named_target.save.should be_false
        duplicate_named_target.errors[:name].should == ['has already been taken']
      end
    end
  end
end
