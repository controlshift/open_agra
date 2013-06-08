module Heartbeat

  def heartbeat(options = {})
    package 'heartbeat', :ensure => :installed
    service 'heartbeat',
      :ensure  => :running,
      :require => package('heartbeat'),
      :restart => '/etc/init.d/heartbeat reload'

    file '/etc/ha.d', :ensure => :directory
    file '/etc/ha.d/authkeys',
      :ensure  => :present,
      :content => template("#{File.dirname(__FILE__)}/templates/authkeys", binding),
      :mode    => '600',
      :notify  => service('heartbeat')

    file '/etc/ha.d/haresources',
      :ensure  => :present,
      :content => template("#{File.dirname(__FILE__)}/templates/haresources", binding),
      :notify  => service('heartbeat')

    file '/etc/ha.d/ha.cf',
      :ensure  => :present,
      :content => template("#{File.dirname(__FILE__)}/templates/ha.cf", binding),
      :notify  => service('heartbeat')
  end

private

  def haresources
    configuration[:heartbeat][:resources].map do |preferred_node, string_or_array_of_resources|
      buffer = ''
      buffer << preferred_node.to_s
      buffer << ' '
      if string_or_array_of_resources.is_a?(Array)
        buffer << string_or_array_of_resources.join(' ')
      else
        buffer << string_or_array_of_resources
      end
      buffer
    end.join("\n")
  end

  def ucast_ip
    opposite_node = configuration[:heartbeat][:nodes].find do |hostname, ip|
      !hostname.to_s.match(Facter.fqdn)
    end
    opposite_node.last
  end

  def ha_config_boolean(key, default = true)
    if key.nil?
      default ? 'on' : 'off'
    else
      ((!!key) == true) ? 'on' : 'off'
    end
  end

end