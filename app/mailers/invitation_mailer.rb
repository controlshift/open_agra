class InvitationMailer < Devise::Mailer
  def send_to_campaign_admin(invitation)
    @organisation = invitation.petition.organisation
    send_invitation(invitation, t('mailers.invitation.send_to_campaign_admin.subject', petition_title: invitation.petition.title))

  end

  def send_to_group_admin(invitation)
    @organisation = invitation.group.organisation
    send_invitation(invitation, t('mailers.invitation.send_to_group_admin.subject', group_title: invitation.group.title))
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
