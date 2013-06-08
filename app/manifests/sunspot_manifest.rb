require "#{File.dirname(__FILE__)}/base_manifest.rb"

class SunspotManifest < BaseManifest

  configure :iptables => build_sunspot_iptables_configuration
  recipe :standalone_sunspot_stack
  recipe :solr_directories
  recipe :god

  recipe :application_packages

  def solr_directories
    file "#{configuration[:deploy_to]}/shared/solr",
      :owner => configuration[:user],
      :group => configuration[:group] || configuration[:user],
      :ensure => :directory

    %w(pids data).each do |dir|
      file "#{configuration[:deploy_to]}/shared/solr/#{dir}",
        :owner => configuration[:user],
        :group => configuration[:group] || configuration[:user],
        :ensure => :directory

      file "#{rails_root}/solr",
        :ensure => :directory

      file "#{rails_root}/solr/#{dir}",
        :ensure => :link,
        :target => "#{configuration[:deploy_to]}/shared/solr/#{dir}"
    end
  end
  
end
