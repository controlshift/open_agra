require "#{File.dirname(__FILE__)}/base_manifest.rb"

class MongodbManifest < BaseManifest

  recipe :default_system_config
  recipe :non_rails_recipes

  configure :mongodb => build_mongodb_configuration
  recipe :mongodb
  recipe :mongodb_replset_command

  configure :iptables => build_mongodb_iptables_configuration
  recipe :iptables

  def scout_dependencies
    gem 'mongo'
    gem 'mongo_ext'
  end

end
