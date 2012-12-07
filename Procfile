web: bundle exec rails server thin -p $PORT
worker: bundle exec rake jobs:work
sidekiq: bundle exec sidekiq -c 40
