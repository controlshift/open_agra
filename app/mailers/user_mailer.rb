class UserMailer < Devise::Mailer
  def contact_campaigner(petition, email)
    subject = t('mailers.user.contact_campaigner.subject', subject: email.subject)
    send_message(petition, email, subject)
  end
  
  def contact_admin(petition, email)
    subject = t('mailers.user.contact_admin.subject', subject: email.subject)
    send_message(petition, email, subject)
  end
  
  # override devise default
  def headers_for(action)
    headers = super(action)
    headers[:from] = "#{resource.organisation.name} <#{resource.organisation.contact_email}>"
    headers[:organisation] = resource.organisation
    headers
  end

  private

  def send_message(petition, email, subject = email.subject)
    @email = email
    @petition = petition

    mail to: email.to_address, subject: subject, from: email.email_with_name, organisation: @petition.organisation
  end
end
