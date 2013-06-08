require "#{File.dirname(__FILE__)}/base_manifest.rb"

class HaproxyManifest < BaseManifest

  configure :ssl => build_ssl_configuration
  configure :haproxy => build_haproxy_configuration
  configure :heartbeat => build_heartbeat_configuration
  configure :iptables => build_web_iptables_configuration

  recipe :standalone_haproxy_stack
    
  def scout_dependencies
    gem 'fastercsv'
  end   
        
end
