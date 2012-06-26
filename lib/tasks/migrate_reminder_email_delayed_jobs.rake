desc "migrate existing reminder of dormant emails delayed jobs"
task migrate_reminder_emails: :environment do
  Delayed::Job.where("handler LIKE '%reminder_check%'").each do |job|
    begin
      yaml = YAML::load(job.handler)
      obj = JSON::parse(yaml.object.to_json)
      reminders = obj['reminders']
      next if reminders >= 2
      
      petition = Petition.find_by_id(obj['petition']['id'])
      unless petition.nil?
        puts "resetting delayed job for petition: #{obj['petition']['slug']}"
        Jobs::PromotePetitionJob.new.schedule_reminder_when_dormant(job.run_at + 1.week, petition)
        if reminders == 0
          Jobs::PromotePetitionJob.new.schedule_reminder_when_dormant(job.run_at + 2.week, petition)
        end
      end
      
      job.destroy
    rescue Exception => e
      puts e.message
    end
  end
end