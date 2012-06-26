namespace :db do
  desc "Delete data except for organisation data."
  task :clear_data => :environment do
    [Signature, PetitionBlastEmail, PetitionFlag, Email, EmailWhiteList, Petition, User].each do |table|
      table.delete_all
    end
    Rake::Task["jobs:clear"].invoke
    puts "om nom nom, i ate everything! (except for organisations)."
  end
end
