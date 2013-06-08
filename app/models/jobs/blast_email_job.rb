module Jobs
  class BlastEmailJob
    include Sidekiq::Worker

    def email_batch_size
      500
    end

    def perform blast_email_id
      blast_email = BlastEmail.find blast_email_id

      if blast_email.is_a?(PetitionBlastEmail)
        finder = blast_email.recipients.select([:id, :email, :token])
      else
        finder = blast_email.recipients.includes(:member)
      end
      finder.find_in_batches(batch_size: email_batch_size) do |batch|
        begin
          BlastEmailWorker.perform_async(blast_email.id, batch.map(&:email), batch.map(&:token))
        rescue Exception => e
          ExceptionNotifier::Notifier.background_exception_notification(e)
        end
      end

      blast_email.update_attribute(:delivery_status, 'delivered')
    end
  end
end