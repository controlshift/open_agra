ENV['REDIS_URL'] = ENV['OPENREDIS_URL']
Sidekiq.configure_server do |config|
  config.redis = { :namespace => "#{Rails.env}-sidekiq" }
end

# When in Unicorn, this block needs to go in unicorn's `after_fork` callback:
Sidekiq.configure_client do |config|
  config.redis = { :namespace => "#{Rails.env}-sidekiq" }
end