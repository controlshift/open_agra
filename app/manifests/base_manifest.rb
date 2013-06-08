require "dotenv"
Dotenv.load("#{ENV['RAILS_ROOT']}/.env.#{ENV['RAILS_ENV']}", "#{ENV['RAILS_ROOT']}/.env")

require "#{File.dirname(__FILE__)}/../../vendor/plugins/moonshine/lib/moonshine.rb"
require "#{File.dirname(__FILE__)}/lib/configuration_builders.rb"

class BaseManifest < Moonshine::Manifest::Rails

  include Moonshine::Postgres9
  include Moonshine::Postgis
  include Moonshine::MultiServer
  include Moonshine::Railsmachine
  include ConfigurationBuilders

  recipe :railsmachine

  on_stage :production do
    recipe :scout
    recipe :scout_dependencies
  end

  recipe :ssh
  recipe :denyhosts
  recipe :github_ssh_config

  def application_packages
    recipe :nodejs
    recipe :postgresql_client
    recipe :ldconfig
    recipe :geos
    recipe :gdal 

    # TODO add any custom system packages here. For example:
    # package 'blah', :ensure => :installed, :before => exec('bundle install')
  end

  def scout_dependencies
  end

  def github_ssh_config
    # sshkey doesn't have user option, so will be created as root
    sshkey 'github.com',
      :ensure => :present,
      :type => 'ssh-rsa',
      :key => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==',
      :target => "/home/#{configuration[:user]}/.ssh/known_hosts",
      :before => exec('bundle install')
    # make sure known_hosts owned by correct user
    file "/home/#{configuration[:user]}/.ssh/known_hosts",
    :ensure => :present,
      :require => sshkey('github.com'),
      :owner => configuration[:user],
      :group => configuration[:group] || configuration[:user]

    end
end
