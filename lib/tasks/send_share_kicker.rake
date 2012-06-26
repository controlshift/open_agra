desc "send kicker email to remind campaigner to share their petition. eg. ORGANISATION='getup'"
task send_share_kicker: :environment do
  organisation_slug = ENV['ORGANISATION']
  organisation = Organisation.find_by_slug!(organisation_slug)
  petitions = Petition.one_signature.where('organisation_id = ?', organisation)
  email_count = 0
  petitions.each do |petition|
    CampaignerMailer.send_share_kicker(petition).deliver
    email_count += 1
  end
  puts "Number of emails sent to campaigners: #{email_count}"
end