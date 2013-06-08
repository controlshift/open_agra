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
         subject: t('mailers.signature.thank_signer.subject', petition_title: @petition.title),
         from: signature.petition.email_from_address,
         content_type: 'text/html',
         organisation: @organisation)
  end
end
