source 'http://rubygems.org'

ruby '1.9.3'

# agra_private is a rails engine for keeping configuration that can't be open-sourced for security reasons.
# You will need to change the git url to your own one.
# A sample agra_private is provided at https://github.com/controlshift/agra_private_sample.git

#gem 'agra_private', path: '/work/agra_private'
gem 'agra_private', git: 'https://github.com/controlshift/agra_private_sample.git'

gem 'rails', '3.2.12'
gem 'pg'

gem 'dotenv'

gem 'devise'
gem 'devise-async'
gem 'simple_form', '2.0.4'
gem 'tabletastic'
gem 'exception_notification', require: 'exception_notifier'
gem 'jquery-rails'
gem 'sidekiq'

gem 'client_side_validations', git: 'https://github.com/bcardarella/client_side_validations.git'
gem 'client_side_validations-simple_form', git: 'https://github.com/dockyard/client_side_validations-simple_form.git'

gem 'blue_state_digital', git: 'https://github.com/controlshift/blue_state_digital.git'
gem 'action_kit_rest',    git: 'https://github.com/controlshift/action_kit_rest.git'
gem 'databasedotcom'
gem 'facebook_share_widget', git: 'https://github.com/controlshift/facebook_share_widget_rails.git'
gem 'rack-rewrite'
gem 'rails_autolink'

gem 'haml-rails'
gem 'coffee-filter'
gem 'cancan'
gem 'sunspot_rails', '2.0.0.pre.120925' #, git: 'git://github.com/sunspot/sunspot.git'
gem 'sunspot_solr', git: 'git://github.com/sunspot/sunspot.git'
gem 'yajl-ruby'
gem 'will_paginate', '~> 3.0'
gem 'exception_notification'
gem 'foreigner'
gem 'paperclip', '~> 2.5.0'
gem 'aws-sdk'
gem 'prawn', git: 'https://github.com/prawnpdf/prawn.git'
gem 'remotipart', '~> 0.4'
gem 'factory_girl_rails'
gem 'faker'
gem 'tinymce-rails', git: 'https://github.com/seanhotw/tinymce-rails.git'
gem 'sendgrid'
gem 'newrelic_rpm'
gem 'newrelic-redis'
gem 'RedCloth'
gem 'seed-fu', '~>2.2.0'
gem 'dalli'
gem 'strip_attributes'
gem 'liquid'
gem 'mobile-fu'
gem 'split', git: 'git://github.com/controlshift/split.git'
gem 'fb_graph'
gem 'omniauth-facebook'
gem 'rack-pjax'
gem 'rest-client'
gem 'heroku'
gem 'retryable'
gem 'going_postal'

gem 'activerecord-postgis-adapter', git: 'https://github.com/controlshift/activerecord-postgis-adapter.git'
gem 'activerecord-postgres-hstore', git: 'git://github.com/engageis/activerecord-postgres-hstore.git'
gem 'simple_captcha', :require => 'simple_captcha', :git => 'https://github.com/woodhull/simple-captcha.git'

gem 'slim'
# if you require 'sinatra' you get the DSL extended to Object
gem 'sinatra', :require => nil

gem 'obscenity'
gem 'capistrano'
gem 'rails-pulse', :git => 'https://github.com/controlshift/pulse.git'
gem 'rails-i18n'
gem 'cache_digests'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'asset_sync'
  gem 'haml-rails'
  gem 'sass-rails',   '~> 3.2.6'
  gem 'coffee-rails', '~> 3.2.2'
  gem 'compass-rails'
  gem 'uglifier'
  gem 'handlebars_assets'
  gem 'turbo-sprockets-rails3'
end

group :test, :development do
  gem 'active_record_query_trace'
  gem 'colorize'
  gem 'rspec-rails'
  gem 'nyan-cat-formatter'
  gem 'annotate', git: 'git://github.com/ctran/annotate_models.git'
  gem 'pry'
  gem 'pry-stack_explorer'
  gem 'debugger-ruby_core_source'
  gem 'pry-debugger'
  gem 'debugger', '1.1.4'
end

group :development, :test, :staging do
  gem 'scrap'
end

group :development do
  gem 'rb-fsevent' #, require: false if RUBY_PLATFORM =~ /darwin/i
  gem 'guard-rspec'
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :test do
  gem 'timecop'
  gem 'database_cleaner'    # required by capybara-webkit because transaction cleaning only supports :rake_test
  gem 'headless'            # required by ubuntu ci server for capybara webkit testing
  gem 'shoulda-matchers'
  gem 'capybara'
  gem 'capybara-webkit', '~>0.11.0'
  gem 'email_spec'
  gem 'sunspot-rails-tester', git: 'git://github.com/nabeta/sunspot-rails-tester.git'
  gem 'webmock'
end

group :profile do
  gem 'ruby-prof'
end

