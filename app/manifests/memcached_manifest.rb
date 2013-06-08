require "#{File.dirname(__FILE__)}/base_manifest.rb"

class MemcachedManifest < BaseManifest

  configure :memcached => build_memcached_configuration
  configure :iptables => build_memcached_iptables_configuration
  recipe :standalone_memcached_stack

  def scout_dependencies
    gem 'memcache-client'
  end

end
