class ModerationMailer < ActionMailer::Base
  def notify_admin_of_new_petition(petition)
    @petition = petition

    subject = "A new petition needs to be moderated"
    mail(to: @petition.organisation.admin_email,
        from: @petition.organisation.admin_email,
        subject: subject,
        organisation: @petition.organisation)
  end

  def notify_admin_of_edited_petition(petition)
    @petition = petition

    subject = "An edited petition needs to be moderated"
    mail(to: @petition.organisation.admin_email,
        from: @petition.organisation.admin_email,
        subject: subject,
        organisation: @petition.organisation)
  end

  def notify_campaigner_of_approval(blast_email)
    @blast_email = blast_email

    subject = "Your email has been approved"
    mail(to: blast_email.from, 
        from: @blast_email.organisation.contact_email_with_name,
        subject: subject, 
        organisation: @blast_email.organisation)
  end
  
  def notify_campaigner_of_rejection(blast_email)
    @blast_email = blast_email
    @new_email_path = blast_email.new_email_path

    subject = "A message from #{@blast_email.organisation.name} about your email"
    mail(to: blast_email.from, 
        from: @blast_email.organisation.contact_email_with_name,
        subject: subject, 
        organisation: @blast_email.organisation)
  end
  
  def notify_admin_of_new_blast_email(blast_email)
    @blast_email = blast_email

    subject = "An email needs to be moderated"
    mail(to: @blast_email.organisation.admin_email,
        from: @blast_email.organisation.admin_email,
        subject: subject, 
        organisation: @blast_email.organisation)
  end
end
