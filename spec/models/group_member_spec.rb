# == Schema Information
#
# Table name: group_members
#
#  id               :integer         not null, primary key
#  group_id         :integer
#  user_id          :integer
#  invitation_email :string(255)
#  invitation_token :string(60)
#

require 'spec_helper'

describe GroupMember do

  let(:group_member) { GroupMember.new }
  let(:group_a) { Factory(:group) }
  let(:group_b) { Factory(:group) }
  let(:user) { Factory(:user) }

  subject { group_member }

  specify { should validate_presence_of(:group_id) }
  specify { should allow_mass_assignment_of(:invitation_email) }
  specify { should allow_mass_assignment_of(:invitation_token) }
  specify { should validate_presence_of(:invitation_email)}
  it 'validates uniqueness of invitation email' do
    Factory(:group_member, user: nil)
    should validate_uniqueness_of(:invitation_email).case_insensitive.scoped_to(:group_id)
  end
  specify { should ensure_length_of(:invitation_token).is_at_most(60) }

  describe '#validate uniqueness of user' do

    context 'user specified' do
      before :each do
        Factory(:group_member, group: group_a, user: user, invitation_email: user.email)
        user_b = Factory(:user)
        Factory(:group_member, group: group_b, user: user_b, invitation_email: user_b.email)
      end

      it 'should allow a new invitation even if the user is inside another group' do
        group_member = Factory.build(:group_member, group: group_b, user: user, invitation_email: user.email)
        group_member.valid?.should be_true
        group_member.save.should be_true
      end

      it 'should not allow a new group_member if the user is already present' do
        group_member = Factory.build(:group_member, group: group_a, user: user, invitation_email: user.email)
        group_member.valid?.should be_false
        group_member.save.should be_false
      end
    end

    context 'no user specified' do
      it "does not validate uniqueness on user id" do
        Factory(:group_member, user: nil, group: group_a)
        group_member = Factory.build(:group_member, user: nil, group: group_a, invitation_email: user.email)
        group_member.valid?.should == true
        group_member.save.should == true
      end
    end

  end

  describe '#strip_attributes' do
    let(:group_member) { Factory(:group_member, invitation_email: " fred@fred.com ", user: nil) }

    it 'should strip attributes' do
      group_member.invitation_email.should == 'fred@fred.com'
    end
  end

  describe 'generate token' do
    it 'should generate token on create' do
      invitation = Factory.build(:group_member, invitation_email: 'test@test.com', user: nil)
      invitation.invitation_token.should be_nil

      invitation.save
      invitation.invitation_token.should_not be_nil
    end

    it 'should not generate token on update' do
      invitation = Factory(:group_member, invitation_email: 'test@test.com', user: nil)
      token = invitation.invitation_token
      invitation.save
      invitation.invitation_token.should == token
    end
  end
end
