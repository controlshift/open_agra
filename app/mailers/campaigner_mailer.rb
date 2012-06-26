include ActionView::Helpers::SanitizeHelper

class CampaignerMailer < ActionMailer::Base
  include SendGrid

  def email_supporters(email, recipient_addresses, tokens)
    @content = sanitize(email.body)
    @petition = email.petition
    @is_campaign_admin = @petition.admins.detect{|user| user == email.from_address}

    sendgrid_category "P#{email.petition.slug}_E#{email.from_address}"
    sendgrid_recipients recipient_addresses
    sendgrid_substitute '___token___', tokens if tokens
    mail(to: 'does-not-matter@controlshiftlabs.com',
         from: email.from,
         subject: email.subject,
         organisation: @petition.organisation)
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
         subject: "Thanks for creating the petition: #{petition.title}",
         from: organisation.contact_email_with_name,
         content_type: 'text/html',
         organisation: organisation) do | format|
      format.html { render text: body }
    end
  end

  def notify_petition_being_marked_as_inappropriate(petition)
    @petition = petition
    organisation = @petition.organisation
    mail(to: @petition.email,
         subject: 'Your campaign has been marked as inappropriate',
         from: organisation.contact_email_with_name,
         organisation: organisation)
  end

  def send_share_kicker(petition)
    send_kicker_email(petition, 'Share with your friends')
  end
  
  def notify_petition_letter_ready_for_download(petition)
    @petition = petition
    organisation = @petition.organisation
    mail(to: @petition.email,
         subject: 'Petition is ready to Deliver',
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
