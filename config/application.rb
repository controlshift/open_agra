require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

#Delayed::Worker.destroy_failed_jobs = false

module Agra
  class Application < Rails::Application

    config.middleware.use Rack::Pjax

    # we need this, because we use psql specific db index definitions for performance.
    # see: http://guides.rubyonrails.org/migrations.html#types-of-schema-dumps
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
    config.filter_parameters += [:password]

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # otherwise, the app tries to access the database, and precompilation fails.
    # see: http://stackoverflow.com/questions/8622297/heroku-cedar-assetsprecompile-has-beef-with-attr-protected
    config.assets.initialize_on_precompile = false
    config.assets.paths << Rails.root.join("vendor", "assets", "fonts")
    config.assets.precompile += [/organisations\/[\w_]+\/application/]
    config.assets.precompile += ['ie7.css']
    config.assets.precompile += ['ie8.css']
    config.assets.precompile += ['mobile.js']
    config.assets.precompile += ['facebook_share.js']
    config.assets.precompile += ['location.js', 'efforts_location.js', 'petition/manage.js', 'create_effort.js', 'petition/contact_user.js']
    config.assets.precompile += ['tinymce-jquery']

    config.action_controller.asset_host = ENV["S3_HOST_ALIAS"]

    if ENV["S3_ENABLED"]
      config.paperclip_options = {
        storage: :s3,
        s3_host_alias: ENV["S3_HOST_ALIAS"],
        url: ':s3_alias_url',
        path: "/:class/:attachment/:id/:style/:filename",
        s3_credentials: {url: :s3_alias_url, access_key_id: ENV["S3_KEY"], secret_access_key: ENV["S3_SECRET"], bucket: ENV["S3_BUCKET"], s3_host_name: ENV["S3_REGION"]},
        s3_headers: { 'Cache-Control' => 'public, max-age=1314000' }
      }
      config.paperclip_file_options = config.paperclip_options.merge({
        path: "/:class/:attachment/:id/:timestamp/:filename"
      })
    else
      config.paperclip_options = {
        url: "/system/:class/:attachment/:id/:style/:filename",
        storage: :filesystem
      }
      config.paperclip_file_options = config.paperclip_options.merge({
        url: "/system/:class/:attachment/:id/:timestamp/:filename"
      })
    end

    config.flagged_petitions_threshold = 5

    ActiveSupport::Deprecation.silenced = true

    WillPaginate.per_page = 10

    # for custom 404 and 500 page.
    config.exceptions_app = self.routes
  end

end

