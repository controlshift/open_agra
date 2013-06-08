module Moonshine
  module Sidekiq
    def sidekiq(sent_options = {})
      default_options = {
        :workers => 1
      }

      options = HashWithIndifferentAccess.new(default_options.merge(configuration[:sidekiq] || {}))

      file "/etc/god/#{configuration[:application]}-sidekiq.god",
        :content => template(File.join(File.dirname(__FILE__), '..', '..', 'templates', 'sidekiq.god.erb'), binding),
        :ensure => :file,
        :notify => exec('restart_god'),
        :require => file('/etc/god/god.conf')
    end
  end
end
