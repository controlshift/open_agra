module Moonshine
  module DJ
    def dj(sent_options = {})
      default_options = {
        :workers => 1
      }

      options = HashWithIndifferentAccess.new(default_options.merge(configuration[:dj] || {}))

      file "/etc/god/#{configuration[:application]}-dj.god",
        :content => template(File.join(File.dirname(__FILE__), '..', '..', 'templates', 'dj.god.erb'), binding),
        :ensure => :file,
        :notify => exec('restart_god'),
        :require => file('/etc/god/god.conf')
    end
  end
end
