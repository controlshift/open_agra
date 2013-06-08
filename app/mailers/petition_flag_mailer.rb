class PetitionFlagMailer < ActionMailer::Base
  def notify_organisation_of_flagged_petition(petition)
    @petition = petition
    
    subject = t('mailers.petition_flag.notify_organisation_of_flagged_petition.subject')
    mail(to: @petition.organisation.admin_email, 
        from: @petition.organisation.admin_email, 
        subject: subject, 
        organisation: @petition.organisation)
  end
end
