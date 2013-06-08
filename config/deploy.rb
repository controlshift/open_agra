set :stages, %w(staging production)
set :default_stage, 'staging'
set :branch, fetch(:branch, "master")

require 'capistrano/ext/multistage' rescue 'YOU NEED TO INSTALL THE capistrano-ext GEM'

after 'god:restart', 'god:sidekiq:restart'

namespace :rake_task do
  desc "Run a task on the sunspot server."
  # run with: cap staging rake:invoke TASK=a_certain_task
  task :invoke, :roles => :sunspot, :no_release => true do
    run("cd #{latest_release} && bundle exec rake #{ENV['TASK']} RAILS_ENV=#{rails_env}")
  end
end

namespace :moonshine do
  task :apply do
    moonshine.multi_server_apply
  end    
end

# install dotenv so it can be used during moonshining
namespace :dotenv do
  task :install do
    sudo 'gem install dotenv --no-rdoc --no-ri'
  end
end
after 'ruby:install', 'dotenv:install' # make sure it gets installed during bootstrap

namespace :sunspot do
  namespace :god do
    task :start, :roles => :sunspot do
      sudo "god start sunspot-solr || true"
    end

    task :stop, :roles => :sunspot do
      sudo "god stop sunspot-solr || true"
    end

    task :restart, :roles => :sunspot do
      sudo "god restart sunspot-solr || true"
    end
  end

  task :reindex, :roles => :sunspot, :no_release => true do
    run "cd #{latest_release} && RAILS_ENV=#{rails_env} bundle exec rake sunspot:solr:reindex"
  end
end
