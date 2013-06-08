require "#{File.dirname(__FILE__)}/base_manifest.rb"

class ApplicationManifest < BaseManifest

  configure :iptables => build_app_iptables_configuration
  recipe :standalone_application_stack

  recipe :application_packages
  recipe :cronjobs
  recipe :passenger_monitor

  def cronjobs
  end
end
