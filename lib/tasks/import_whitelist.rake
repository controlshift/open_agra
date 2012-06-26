require 'csv'

desc "import csv file of email addresses for whitelist. eg. FILE=whitelist.csv"
task import_whitelist: :environment do
  csv_file = ENV['FILE']

  success_count = 0
  failure_count = 0
  CSV.foreach csv_file do |row|
    email = row[0]
    next if email.blank?
    email_white_list = EmailWhiteList.new(email: email)
    if email_white_list.valid?
      email_white_list.save!
      success_count += 1
    else
      error = email_white_list.errors.full_messages.join(",")
      puts "Failure: #{email}, cause: #{error}"
      failure_count += 1
    end
  end

  puts "Whitelist records created: #{success_count}"
  puts "Failures: #{failure_count}"
end

desc "import single email to whitelist"
task add_to_whitelist: :environment do
  email = ENV['EMAIL']
  email_white_list = EmailWhiteList.create(email: email)
  puts "Created whitelist entry for: #{email}"
end

