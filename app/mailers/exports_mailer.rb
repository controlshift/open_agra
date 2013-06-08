class ExportsMailer < ActionMailer::Base
  def send_generation_confirmation(csv_report)
    @csv_report = csv_report
    @user = @csv_report.exported_by
    @organisation = @user.organisation

    mail(to: @user.email,
      from: @csv_report.export.organisation.contact_email_with_name,
      subject: t('mailers.export.send_generation_confirmation.subject'),
      organisation: @organisation,
      content_type: 'text/html').deliver
  end
end
