require "#{File.dirname(__FILE__)}/base_manifest.rb"

class WorkerManifest < BaseManifest

  configure :iptables => build_worker_iptables_configuration
  recipe :standalone_worker_stack

  recipe :application_packages

  recipe :god
  recipe :dj
  recipe :sidekiq

  def scout_dependencies
    gem 'redis'
    gem 'sidekiq'
    gem 'activerecord'
  end
  
end
