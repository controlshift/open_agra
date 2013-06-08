include ActionView::Helpers::SanitizeHelper

class CampaignerMailer < ActionMailer::Base
  include SendGrid
  add_template_helper(UnsubscribeHelper)

  def email_supporters(email, recipient_addresses, tokens)
    @email = email
    @content = sanitize(email.body)
    @source = email.source
    @can_be_unsubscribed = email.can_be_unsubscribed? && tokens.present?
    sendgrid_category email.sendgrid_category
    sendgrid_recipients recipient_addresses
    sendgrid_substitute '___token___', tokens if tokens
    mail(to: 'does-not-matter@controlshiftlabs.com',
         from: email.from,
         subject: email.subject,
         organisation: @source.organisation)
  end

  def thanks_for_creating(petition)
    organisation = petition.organisation
    recipient = petition.user
    
    context = {
      'organisation' => organisation,
      'petition' => petition, 
      'recipient' => recipient
    }
    
    if petition.effort && petition.effort.thanks_for_creating_email.present?
      body = petition.effort.render(:thanks_for_creating_email, context).html_safe
    else
      body = Content.content_for('welcome_email', organisation, context).html_safe
    end
    
    mail(to: recipient.email,
         subject: t('mailers.campaigner.thanks_for_creating.subject', petition_title: petition.title),
         from: organisation.contact_email_with_name,
         content_type: 'text/html',
         organisation: organisation) do | format|
      format.html { render text: body }
    end
  end

  def notify_petition_being_marked_as_inappropriate(petition)
    @petition = petition
    organisation = @petition.organisation
    if @petition.user
      mail(to: @petition.email,
           subject: t('mailers.campaigner.notify_petition_being_marked_as_inappropriate.subject'),
           from: organisation.contact_email_with_name,
           organisation: organisation)
    else
      raise "#{@petition.slug} has no user and a status of #{petition.admin_status}"
    end
  end

  def send_share_kicker(petition)
    send_kicker_email(petition, t('mailers.campaigner.send_share_kicker.subject'))
  end
  
  def notify_petition_letter_ready_for_download(petition, user)
    @petition = petition
    @user = user
    organisation = @petition.organisation
    mail(to: user.email,
         subject: t('mailers.campaigner.notify_petition_letter_ready_for_download.subject'),
         from: organisation.contact_email_with_name,
         organisation: organisation)
  end

  private

  def send_kicker_email(petition, subject)
    @petition = petition

    mail(to: petition.email,
         from: petition.organisation.contact_email_with_name,
         subject: subject,
         organisation: petition.organisation)
  end

end
