class BlastEmailWorker
  include Sidekiq::Worker

  def perform(blast_email_id, emails, tokens)
    email = BlastEmail.find(blast_email_id)
    CampaignerMailer.email_supporters(email, emails, tokens).deliver
  end
end