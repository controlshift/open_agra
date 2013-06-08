# == Schema Information
#
# Table name: petition_flags
#
#  id          :integer         not null, primary key
#  petition_id :integer
#  user_id     :integer
#  ip_address  :string(255)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#  reason      :text
#

require "spec_helper"

describe PetitionFlag do

  describe "model value validation" do
    before(:each) do
      @flag = PetitionFlag.new
    end

    subject { @flag }

    it { should validate_presence_of(:petition_id) }
    it { should validate_presence_of(:ip_address) }

    it "should accept valid ip adddress format" do
      should allow_value("192.168.1.1").for(:ip_address)
    end

    it "should reject invalid ip adddress format" do
      should_not allow_value("999.999.999.999").for(:ip_address)
    end
  end

  describe "model uniqueness validation" do
    before(:each) do
      user = Factory(:user)
      petition = Factory(:petition)
      @valid_attr = {user: user, petition: petition, ip_address: "127.0.0.1", reason: "some reason"}
    end

    context "user is not log in" do

      before(:each) do
        @not_log_in_attr = @valid_attr.merge(user: nil)
      end

      it "should not be able to flag the same petition with the same ip address" do
        PetitionFlag.create(@not_log_in_attr)

        another_petition = PetitionFlag.new
        another_petition.attributes = @not_log_in_attr

        another_petition.should have(1).error_on(:ip_address)
      end

      it "should able to flag different petition with the same ip address" do

        another_petition = Factory(:petition)

        PetitionFlag.create!(@not_log_in_attr)
        PetitionFlag.create!(@not_log_in_attr.merge(petition: another_petition))
      end

      it "should be able to flag a petition as different user with different ip address" do

        PetitionFlag.create!(@not_log_in_attr)
        PetitionFlag.create!(@not_log_in_attr.merge(ip_address: "127.0.0.0"))
      end
    end

    context "user is log in" do

      it "should not be able to flag the same petition with different ip address" do
        PetitionFlag.create(@valid_attr)

        another_petition = PetitionFlag.new
        another_petition.attributes = @valid_attr.merge(ip_address: "127.0.0.0")

        another_petition.should have(1).error_on(:user_id)
      end

      it "should be able to flag a petition as different user with the same ip address" do
        another_user = Factory(:user)
        PetitionFlag.create!(@valid_attr)
        PetitionFlag.create!(@valid_attr.merge(user: another_user))
      end
    end
  end

  describe "#created_after" do
    before :each do
      @time = Time.now
      @time_past = Factory(:petition_flag, created_at: @time-1)
      @time_now = Factory(:petition_flag, created_at: @time)
      @time_future = Factory(:petition_flag, created_at: @time+1)
    end

    it "should return flags created after specific time" do
      PetitionFlag.created_after(@time).should_not include(@time_past)
      PetitionFlag.created_after(@time).should_not include(@time_now)
      PetitionFlag.created_after(@time).should include(@time_future)
    end

    it "should return all flags if time is null" do
      PetitionFlag.created_after(nil).should =~ [@time_past, @time_now, @time_future]
    end
  end

end
