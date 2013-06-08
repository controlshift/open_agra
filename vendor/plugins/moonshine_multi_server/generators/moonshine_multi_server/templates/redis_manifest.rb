require "#{File.dirname(__FILE__)}/base_manifest.rb"

class RedisManifest < BaseManifest

  configure :iptables => build_redis_iptables_configuration
  configure :sysctl => {'vm.overcommit_memory' => 1}
  configure :redis => build_redis_configuration
  recipe :standalone_redis_stack

  def scout_dependencies
    gem 'redis'

    # make sure in redis group, to access /var/log/redis/redis-server
    exec "usermod -a -G redis #{configuration[:user]}",
      :unless => "groups #{configuration[:user]} | egrep '\\bredis\\b'",
      :before => package('scout'),
      :require => exec('install redis')
  end  

end
