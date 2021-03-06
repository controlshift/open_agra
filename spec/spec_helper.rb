require 'rubygems'
require 'webmock/rspec'

# By default, allow all http connections otherwise we will need to stub other connections (e.g. solr).
WebMock.allow_net_connect!


ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'email_spec'
require 'paperclip/matchers'
require 'sidekiq/testing'
# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join('spec/support/**/*.rb')].each {|f| require f}
load 'support/speed_up_paperclip.rb'
$original_sunspot_session = Sunspot.session

RSpec.configure do |config|
  config.include Devise::TestHelpers, type: :controller
  config.include Paperclip::Shoulda::Matchers, type: :model
  config.filter_run_excluding external: true

  config.before :suite do
   SeedFu.seed
  end

  config.before :each do
    Split.redis.flushall
    Sunspot.session = Sunspot::Rails::StubSessionProxy.new($original_sunspot_session)
  end

  config.before :each, :solr => true do
    Sunspot::Rails::Tester.start_original_sunspot_session
    Sunspot.session = $original_sunspot_session
    Sunspot.remove_all!
    Rails.cache.clear
  end

  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  #config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  #This allows you to use the core set of syntax methods (build, build_stubbed,
  #create, attributes_for, and their *_list counterparts) without having to call them on FactoryGirl directly
  config.include FactoryGirl::Syntax::Methods

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false
end
