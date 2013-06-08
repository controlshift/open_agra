if Rails.env.development? || Rails.env.test?
  require 'rspec/core/rake_task'

  desc "Run all external tests"
  RSpec::Core::RakeTask.new(:external => 'db:test:prepare') do |test|
    test.pattern = FileList['./spec/external/**/*.rb']
  end

end
