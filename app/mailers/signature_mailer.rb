class SignatureMailer < ActionMailer::Base
  def thank_signer(signature)
    @signature = signature
    @petition = signature.petition
    @organisation = @petition.organisation

    @context = {
      'organisation' => @organisation,
      'petition' => @petition,
      'signature' => signature
    }

    mail(to: signature.email,
         from: signature.petition.organisation.contact_email_with_name,
         subject: "Thanks for signing #{@petition.title}",
         content_type: 'text/html',
         organisation: @organisation)
  end
end
