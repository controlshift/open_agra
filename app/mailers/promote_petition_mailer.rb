class PromotePetitionMailer < ActionMailer::Base
  def achieved_signature_goal(petition)
    @petition = petition
    mail_to_campaigner(t('mailers.promote.achieved_signature_goal.subject'))
  end

  def encourage(petition)
    @petition = petition
    mail_to_campaigner(t('mailers.promote.encourage.subject'))
  end

  def reminder_when_dormant(petition)
    @petition = petition
    mail_to_campaigner(@petition.title)
  end

  def send_launch_kicker(petition)
    @petition = petition
    mail_to_campaigner(t('mailers.promote.send_launch_kicker.subject'))
  end

  def mail_to_campaigner(subject)
    @organisation = @petition.organisation
    @context = {
      'petition' => @petition,
      'recipient' => @petition.user
    }
    
    mail(to: @petition.email, subject: subject, from: @petition.organisation.contact_email_with_name, organisation: @petition.organisation)
  end
end
