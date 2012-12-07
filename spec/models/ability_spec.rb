require 'spec_helper'
require 'cancan/matchers'

describe 'Ability' do
  let(:organisation) {Factory(:organisation)}
  describe 'as guest' do
    before(:each) do
      @ability = Ability.new(nil)
    end

    [:petition, :user, :effort, :story, :group, :category, :organisation].each do | klass|
      specify {@ability.should_not be_able_to(:manage, klass)}
    end
  end

  describe 'as an admin' do
    before :each do
      admin = Factory(:admin)
      @ability = Ability.new(admin)
    end

    specify {@ability.should be_able_to(:manage, :all)}
  end

  describe 'as an org_admin' do
    before :each do
      org_admin = Factory(:org_admin, organisation: organisation)
      @ability = Ability.new(org_admin)
    end

    [:petition, :user, :effort, :story, :group, :category].each do | klass|
      it "should can manage #{klass} if from the same org" do
        klass_object = Factory(klass, organisation: organisation)
        @ability.should be_able_to(:manage, klass_object)
      end

      it "should not can manage #{klass} if from different org" do
        klass_object = Factory(klass, organisation: Factory(:organisation))
        @ability.should_not be_able_to(:manage, klass_object)
      end
    end

    specify { @ability.should be_able_to(:manage, organisation) }
    specify { @ability.should_not be_able_to(:manage, Factory(:organisation)) }
  end

  describe 'as a petition owner' do
    before(:each) do
      petition_owner = Factory(:user, organisation: organisation)
      @petition = Factory(:petition, user: petition_owner, organisation: organisation)
      @ability = Ability.new(petition_owner)
    end

    specify {@ability.should be_able_to(:manage, @petition)}
    specify {@ability.should_not be_able_to(:manage, Factory(:petition, organisation: organisation))}
  end

  describe 'as a petition admin' do
    before(:each) do
      petition_admin = Factory(:user, organisation: organisation)
      @petition = Factory(:petition, organisation: organisation)
      Factory(:campaign_admin, petition: @petition, user: petition_admin, invitation_email: petition_admin.email)
      @ability = Ability.new(petition_admin)
    end

    specify {@ability.should be_able_to(:manage, @petition)}
    specify {@ability.should_not be_able_to(:manage, Factory(:petition, organisation: organisation))}
  end

  describe 'as a group admin' do
    before(:each) do
      group_admin = Factory(:user, organisation: organisation)
      @group = Factory(:group, organisation: organisation)
      Factory(:group_member, group: @group, user: group_admin, invitation_email: group_admin.email)
      @ability = Ability.new(group_admin)
    end

    specify {@ability.should be_able_to(:manage, @group)}
    specify {@ability.should_not be_able_to(:manage, Factory(:group, organisation: organisation))}
  end

  context 'as a normal user' do
    before(:each) do
      normal_user = create(:user, organisation: organisation)
      @petition = create(:petition_without_leader, organisation: organisation)
      @ability = Ability.new(normal_user)
    end

    it 'should let normal user update petitions without leader' do
      @ability.should be_able_to(:update, @petition)
    end

    it 'should not let normal user update petitions already have leader' do
      petition_owner = create(:user, organisation: organisation)
      @petition.user = petition_owner
      @petition.save
      @ability.should_not be_able_to(:update, @petition)
    end
  end
end