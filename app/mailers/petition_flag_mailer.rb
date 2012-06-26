class PetitionFlagMailer < ActionMailer::Base
  def notify_organisation_of_flagged_petition(petition)
    @petition = petition
    
    subject = "A petition has been flagged"
    mail(to: @petition.organisation.admin_email, 
        from: @petition.organisation.admin_email, 
        subject: subject, 
        organisation: @petition.organisation)
  end
end
