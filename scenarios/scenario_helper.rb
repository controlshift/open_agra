# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'capybara/rspec'
require 'headless'
require 'webmock/rspec'
require 'sidekiq/testing/inline'

Dir[Rails.root + "scenarios/helpers/*.rb"].each {|file|  require file }
$original_sunspot_session = Sunspot.session

# TODO: Rick, 2011-12-20 - RSpec 2.7.0 and Capybara 1.1.2 do not handle exit codes from invoked processes as expected.
# The upshot of this is that when capybara-webkit runs its end of suite browser teardown (exit 0) it masks any failing scenarios (exit 1).
# When an official patch makes it into either gem we should be able to remove ebeigart's workaround.
# https://github.com/jnicklas/capybara/pull/463#issuecomment-1887393
module Kernel
  alias :__at_exit :at_exit
  def at_exit(&block)
    __at_exit do
      exit_status = $!.status if $!.is_a?(SystemExit)
      block.call
      exit exit_status if exit_status
    end
  end
end

class Capybara::Driver::Webkit
  class Browser
    def server_pipe_and_pid(server_path)
      cmdline = [server_path]
      cmdline << "--ignore-ssl-errors" if @ignore_ssl_errors
      $stderr.reopen("/dev/null", "w")
      pipe = IO.popen(cmdline.join(" "))
      $stderr.reopen IO.new(2)
      [pipe, pipe.pid]
    end
  end
end

Rails.application.config.assets.paths << "scenarios/support/assets"

RSpec.configure do |config|

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
  config.use_transactional_fixtures = false

  config.before :suite do
    SeedFu.seed
  end

  config.before :each do
    if Capybara.current_driver == :rack_test
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.start
    else
      DatabaseCleaner.strategy = :truncation, {:except => %w(spatial_ref_sys)} # Leave the postgis table alone
    end

    # By default, allow all http connections otherwise we will need to stub other connections (e.g. solr).
    WebMock.allow_net_connect!
    configure_current_organisation
  end

  config.after :each do
    DatabaseCleaner.clean
    Rails.cache.clear
  end

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  #This allows you to use the core set of syntax methods (build, build_stubbed,
  #create, attributes_for, and their *_list counterparts) without having to call them on FactoryGirl directly
  config.include FactoryGirl::Syntax::Methods

  config.before :each do
    Sunspot::Rails::Tester.start_original_sunspot_session
    Sunspot.session = $original_sunspot_session
    Sunspot.remove_all!
  end
end

Capybara.javascript_driver = :webkit

headless = Headless.new(:display => Process.pid, :reuse => false)
headless.start

def configure_current_organisation
  @current_organisation = Factory(:organisation, notification_url: "http://any.url.com", slug: "default")
  # using default slug for doing all the testing.
  # If you aren't sure what's going on try saving the page by using "save_and_open_page"
  stub_request(:any, @current_organisation.notification_url)
  Organisation.stub(:find_by_host) { @current_organisation }
end
