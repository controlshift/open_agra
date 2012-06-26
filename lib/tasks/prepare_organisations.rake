
namespace :db do

  DEFAULT_ORG_ATTRIBUTES = {name: "Default Org", slug: 'default', host: 'localhost', contact_email: 'info@controlshiftlabs.com', admin_email: 'info@controlshiftlabs.com'}

  desc "prepare database for organisation model"
  task :prepare_organisation => :environment do
    Organisation.create!(DEFAULT_ORG_ATTRIBUTES)
  end

  task :update_default_organisation_for_white_labelling => :environment do
    o = Organisation.first
    o.attributes = DEFAULT_ORG_ATTRIBUTES
    o.save!
  end

  task :launch_claimed_petitions => :environment do
    Petition.not_orphan.each do |petition|
      p "launching: #{petition.title}"
      petition.launched = true
      petition.save!
    end
  end
end
