require 'spec_helper'

describe InvitationMailer do

  let(:group_admin_invitation) { Factory(:group_member, user: nil) }
  let(:campaign_admin_invitation) { Factory(:campaign_admin, user: nil) }

  it 'should send invitation to new administrator of a group' do
    invitation_mailer = InvitationMailer.send_to_group_admin(group_admin_invitation)
    invitation_mailer.subject.should == "You're Invited to #{group_admin_invitation.group.title}"
    invitation_mailer.to.should == [group_admin_invitation.invitation_email]
    invitation_mailer.from.should == [group_admin_invitation.group.organisation.contact_email]
    invitation_mailer.body.should include("#{group_invitation_path(group_admin_invitation.group, group_admin_invitation, group_member: {invitation_token: group_admin_invitation.invitation_token})}")
  end

  it 'should send invitation to new administrator of a petition' do
    invitation_mailer = InvitationMailer.send_to_campaign_admin(campaign_admin_invitation)
    invitation_mailer.subject.should == "You're invited to be admin of '#{campaign_admin_invitation.petition.title}'"
    invitation_mailer.to.should == [campaign_admin_invitation.invitation_email]
    invitation_mailer.from.should == [campaign_admin_invitation.petition.organisation.contact_email]
    invitation_mailer.body.should include("#{petition_admin_path(campaign_admin_invitation.petition, campaign_admin_invitation, campaign_admin: {invitation_token: campaign_admin_invitation.invitation_token})}")
  end
end
