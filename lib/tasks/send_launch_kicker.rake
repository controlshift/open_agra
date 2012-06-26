desc "send kicker email to remind campaigner to share their petition. eg. ORGANISATION='getup'"
task send_launch_kicker: :environment do
  organisation_slug = ENV['ORGANISATION']
  organisation = Organisation.find_by_slug!(organisation_slug)
  petitions = Petition.not_orphan.where(launched: false).where('organisation_id = ?', organisation)
  email_count = 0
  petitions.each do |petition|
    PromotePetitionMailer.send_launch_kicker(petition).deliver
    email_count += 1
  end
  puts "Number of emails sent to campaigners: #{email_count}"
end