class ModerationMailer < ActionMailer::Base
  def notify_admin_of_new_petition(petition)
    @petition = petition

    subject = t('mailers.moderation.notify_admin_of_new_petition.subject')
    mail(to: @petition.organisation.admin_email,
        from: @petition.organisation.admin_email,
        subject: subject,
        organisation: @petition.organisation)
  end

  def notify_admin_of_edited_petition(petition)
    @petition = petition

    subject = t('mailers.moderation.notify_admin_of_edited_petition.subject')
    mail(to: @petition.organisation.admin_email,
        from: @petition.organisation.admin_email,
        subject: subject,
        organisation: @petition.organisation)
  end

  def notify_campaigner_of_approval(blast_email)
    @blast_email = blast_email

    to_address = blast_email.petition ? blast_email.petition.email : blast_email.from

    subject = t('mailers.moderation.notify_campaigner_of_approval.subject')
    mail(to: to_address,
        from: @blast_email.organisation.contact_email_with_name,
        subject: subject, 
        organisation: @blast_email.organisation)
  end
  
  def notify_campaigner_of_rejection(blast_email)
    @blast_email = blast_email
    @new_email_path = blast_email.new_email_path

    to_address = blast_email.petition ? blast_email.petition.email : blast_email.from

    subject = t('mailers.moderation.notify_campaigner_of_rejection.subject', org_name: @blast_email.organisation.name)
    mail(to: to_address,
        from: @blast_email.organisation.contact_email_with_name,
        subject: subject, 
        organisation: @blast_email.organisation)
  end
  
  def notify_admin_of_new_blast_email(blast_email)
    @blast_email = blast_email

    subject = t('mailers.moderation.notify_admin_of_new_blast_email.subject')
    mail(to: @blast_email.organisation.admin_email,
        from: @blast_email.organisation.admin_email,
        subject: subject, 
        organisation: @blast_email.organisation)
  end
end
