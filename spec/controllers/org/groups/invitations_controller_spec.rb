require 'spec_helper'

describe Org::Groups::InvitationsController do
  include_context 'setup_default_organisation'

  describe '#create' do
    let(:group) { Factory(:group, organisation: @organisation) }
    let(:email) { 'email@emailfake.com' }

    before :each do
      org_admin = Factory(:org_admin, organisation: @organisation)
      sign_in(org_admin)
    end

    context 'user has not been invited yet' do
      before :each do
        GroupMember.stub(:find_by_invitation_email_and_group_id).with(email, group.id).and_return(nil)
      end

      it { should_send_invitation }
    end

    context 'user has already been invited' do
      before :each do
        @invitation = mock
        GroupMember.stub(:find_by_invitation_email_and_group_id).with(email, group.id).and_return(@invitation)
      end

      it 'resends same invitation' do
        mock_send_invitation(@invitation)

        post :create, group_id: group.slug, group_member: {invitation_email: email}

        response.should redirect_to(org_group_users_path(group))
        flash.notice.should include("has been sent to #{email}")
      end
    end

    context 'invalid email format or any invitation errors' do
      it 'should redirect to users#index with an alert' do
        post :create, group_id: group.slug, group_member: {invitation_email: 'moi@'}
        response.should redirect_to org_group_users_path(group)
        flash.alert.should_not be_nil
        flash.alert.should_not == ""
      end
    end
  end

  def mock_send_invitation(invitation)
    delayed_job = mock
    delayed_job.should_receive(:send_to_group_admin).with(invitation)
    InvitationMailer.stub(:delay) { delayed_job }
  end

  def should_send_invitation(user = nil)
    invitation = mock
    GroupMember.should_receive(:new).with(invitation_email: email).and_return(invitation)
    invitation.should_receive(:group=).with(group)
    invitation.should_receive(:user=).with(@user)
    invitation.should_receive(:save).and_return(true)
    mock_send_invitation(invitation)

    post :create, group_id: group.slug, group_member: {invitation_email: email}

    response.should redirect_to(org_group_users_path(group))
    flash.notice.should include("has been sent to #{email}")
  end
end
