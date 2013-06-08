require "#{File.dirname(__FILE__)}/base_manifest.rb"

class RedisManifest < BaseManifest

  configure :iptables => build_redis_iptables_configuration
  configure :sysctl => {'vm.overcommit_memory' => 1}
  configure :redis => build_redis_configuration
  recipe :standalone_redis_stack

  def scout_dependencies
    gem 'redis'
  end
end
