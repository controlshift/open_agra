require 'sidekiq/middleware/i18n'
redis_config = if ENV['REDIS_URL']
                 { :url => ENV['REDIS_URL'] }
               else
                 {:url => "redis://localhost:6379"}
               end
redis_config[:namespace] = "#{Rails.env}-sidekiq"

Split.redis = redis_config[:url]

Sidekiq.configure_server do |config|
  config.redis = redis_config
  database_url = ENV['DATABASE_URL']
  if(database_url)
    ENV['DATABASE_URL'] = "#{database_url}?pool=20"
    ActiveRecord::Base.establish_connection
  end
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end

# from https://github.com/mperham/sidekiq/wiki/Problems-and-Troubleshooting
if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    Sidekiq.configure_client do |config|
      config.redis = { :size => 1 }.merge(redis_config)
    end if forked
  end
end
