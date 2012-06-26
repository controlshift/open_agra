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
    @petition = blast_email.petition
    
    subject = "Your email has been approved"
    mail(to: blast_email.from, 
        from: @petition.organisation.contact_email_with_name, 
        subject: subject, 
        organisation: @petition.organisation)
  end
  
  def notify_campaigner_of_rejection(blast_email)
    @blast_email = blast_email
    @petition = blast_email.petition
    
    subject = "Your email has been deemed inappropriate"
    mail(to: blast_email.from, 
        from: @petition.organisation.contact_email_with_name, 
        subject: subject, 
        organisation: @petition.organisation)
  end
  
  def notify_admin_of_new_blast_email(blast_email)
    @blast_email = blast_email
    @petition = blast_email.petition
    @blast_email = blast_email

    subject = "An email needs to be moderated"
    mail(to: @petition.organisation.admin_email, 
        from: @petition.organisation.admin_email, 
        subject: subject, 
        organisation: @petition.organisation)
  end
end
