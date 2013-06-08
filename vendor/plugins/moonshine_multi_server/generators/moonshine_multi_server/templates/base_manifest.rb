require "#{File.dirname(__FILE__)}/../../vendor/plugins/moonshine/lib/moonshine.rb"
require "#{File.dirname(__FILE__)}/lib/configuration_builders.rb"

class BaseManifest < Moonshine::Manifest::Rails

<%- if postgresql? %>
  include Moonshine::Postgres9
<%- end %>
  include Moonshine::MultiServer
  include ConfigurationBuilders

  on_stage :production do
    recipe :scout
    recipe :scout_dependencies
  end

  recipe :ssh
  recipe :denyhosts

  def application_packages
<%- if asset_pipeline? -%>
    recipe :nodejs

<%- end -%>
<%- if postgresql? -%>
    recipe :postgresql_client
<%- end -%>
    # TODO add any custom system packages here. For example:
    # package 'blah', :ensure => :installed, :before => exec('bundle install')
  end

  def scout_dependencies
  end
end
