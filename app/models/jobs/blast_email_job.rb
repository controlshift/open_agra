module Jobs
  class BlastEmailJob
    def email_batch_size
      1000
    end

    def initialize(blast_email)
      @blast_email = blast_email
    end

    def perform
      recipients = @blast_email.petition.signatures.subscribed

      # "SendGrid engineer told me it's best to keep the number of recipients to <= 1,000 per delivery"
      # https://github.com/stephenb/sendgrid

      recipients.each_slice(email_batch_size) do |batch|
        begin
          CampaignerMailer.email_supporters(@blast_email, batch.map(&:email), batch.map(&:token)).deliver
        rescue Exception => e
          ExceptionNotifier::Notifier.background_exception_notification(e)
        end
      end

      @blast_email.update_attribute(:delivery_status, 'delivered')
    end
  end
end