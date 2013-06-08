if Rails.env.development? || Rails.env.test?

  require 'rubygems'
  require 'rspec/core/rake_task'

  desc "Run all scenario tests"
  RSpec::Core::RakeTask.new(:scenarios => 'db:test:prepare') do |t|
    t.pattern = FileList['./scenarios/*.rb'].exclude("./scenarios/scenario_helper.rb")
    # t.rspec_opts = ["-c"]
    #t.rspec_opts = ["-c", "--format NyanCatFormatter"]
  end

end
