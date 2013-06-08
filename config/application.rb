require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'active_record/connection_adapters/postgis_adapter/railtie'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test profile)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

#Delayed::Worker.destroy_failed_jobs = false

module Agra
  class Application < Rails::Application

    # don't attempt to auto-require the moonshine manifests into the rails env
    config.paths['app/manifests'] = 'app/manifests'
    config.paths['app/manifests'].skip_eager_load!

    config.middleware.use Rack::Pjax

    # we need this, because we use psql specific db index definitions for performance.
    # see: http://guides.rubyonrails.org/migrations.html#types-of-schema-dumps
    # According to the postgis adapter, this will not work properly with geometry. Uh oh.
    config.active_record.schema_format =  :sql

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths += Dir[Rails.root.join('lib', '**/')] + Dir[Rails.root.join('app', 'models', 'validators')]

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :salesforce_consumer_key, :salesforce_consumer_secret, :salesforce_security_token,
                                 :bsd_api_id, :bsd_api_secret, :fb_app_id, :fb_app_secret, :action_kit_username, :action_kit_password]

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.i18n.available_locales = ['en','en-IN']
    # otherwise, the app tries to access the database, and precompilation fails.
    # see: http://stackoverflow.com/questions/8622297/heroku-cedar-assetsprecompile-has-beef-with-attr-protected
    config.assets.initialize_on_precompile = false
    config.assets.paths << Rails.root.join("vendor", "assets", "fonts")
    config.assets.precompile += [/organisations\/[\w_]+\/application/]
    config.assets.precompile += ['ie7.css']
    config.assets.precompile += ['ie8.css']
    config.assets.precompile += ['jquery.Jcrop.css']
    config.assets.precompile += ['mobile.js']
    config.assets.precompile += ['facebook_share.js']
    config.assets.precompile += ['facebook_share_widget/facebook_friend_view.js']
    config.assets.precompile += ['location.js', 'efforts_location.js', 'petition/manage.js', 'petition/sidebar-resize.js', 'create_effort.js', 'petition/contact_user.js']
    config.assets.precompile += ['tinymce-jquery', 'jquery.Jcrop.js', 'petition/show.js', 'jquery.jcarousel.min.js', 'markerwithlabel_packed.js', 'markerclusterer_packed.js']
    config.flagged_petitions_threshold = 5

    ActiveSupport::Deprecation.silenced = true

    WillPaginate.per_page = 10

    # for custom 404 and 500 page.
    config.exceptions_app = self.routes
  end

end

