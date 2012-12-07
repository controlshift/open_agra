# == Schema Information
#
# Table name: campaign_admins
#
#  id               :integer         not null, primary key
#  petition_id      :integer
#  user_id          :integer
#  invitation_email :string(255)
#  invitation_token :string(60)
#

require 'spec_helper'

describe CampaignAdmin do

  let(:campaign_admin) { CampaignAdmin.new }
  let(:petition_a) { Factory(:petition) }
  let(:petition_b) { Factory(:petition) }
  let(:user) { Factory(:user) }

  subject { campaign_admin }

  specify { should validate_presence_of(:petition_id) }
  specify { should allow_mass_assignment_of(:invitation_email) }
  specify { should allow_mass_assignment_of(:invitation_token) }
  specify { should validate_presence_of(:invitation_email)}
  it 'validates uniqueness of invitation email' do
    Factory(:campaign_admin, user: nil)
    should validate_uniqueness_of(:invitation_email).case_insensitive.scoped_to(:petition_id)
  end
  specify { should ensure_length_of(:invitation_token).is_at_most(60) }

  describe '#validate uniqueness of user' do

    context 'user specified' do
      before :each do
        Factory(:campaign_admin, petition: petition_a, user: user, invitation_email: user.email)
        user_b = Factory(:user)
        Factory(:campaign_admin, petition: petition_b, user: user_b, invitation_email: user_b.email)
      end

      it 'should allow a new invitation even if the user is an admin of another petition' do
        campaign_admin = Factory.build(:campaign_admin, petition: petition_b, user: user, invitation_email: user.email)
        campaign_admin.valid?.should be_true
      end

      it 'should not allow a new campaign_admin if the user is already present' do
        campaign_admin = Factory.build(:campaign_admin, petition: petition_a, user: user, invitation_email: user.email)
        campaign_admin.valid?.should be_false
      end
    end

    context 'no user specified' do
      it "does not validate uniqueness on user id" do
        Factory(:campaign_admin, user: nil, petition: petition_a)
        campaign_admin = Factory.build(:campaign_admin, user: nil, petition: petition_a, invitation_email: user.email)
        campaign_admin.valid?.should == true
      end
    end

  end

  describe '#strip_attributes' do
    let(:campaign_admin) { Factory(:campaign_admin, invitation_email: " fred@fred.com ", user: nil) }

    it 'should strip attributes' do
      campaign_admin.invitation_email.should == 'fred@fred.com'
    end
  end

  describe 'generate token' do
    it 'should generate token on create' do
      invitation = Factory.build(:campaign_admin, invitation_email: 'test@test.com', user: nil)
      invitation.invitation_token.should be_nil

      invitation.save
      invitation.invitation_token.should_not be_nil
    end

    it 'should not generate token on update' do
      invitation = Factory(:campaign_admin, invitation_email: 'test@test.com', user: nil)
      token = invitation.invitation_token
      invitation.save
      invitation.invitation_token.should == token
    end
  end
end
