class InvitationMailer < Devise::Mailer
  def send_to_campaign_admin(invitation)
    @organisation = invitation.petition.organisation
    send_invitation(invitation, "You're invited to be admin of '#{invitation.petition.title}'")

  end

  def send_to_group_admin(invitation)
    @organisation = invitation.group.organisation
    send_invitation(invitation, "You're Invited to #{invitation.group.title}")
  end

  private

  def send_invitation(invitation, subject)
    @invitation = invitation
    mail(to: @invitation.invitation_email,
         subject: subject,
         from: @organisation.contact_email_with_name,
         organisation: @organisation)
  end
end
