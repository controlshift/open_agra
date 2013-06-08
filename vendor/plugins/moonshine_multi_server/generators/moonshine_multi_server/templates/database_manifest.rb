require "#{File.dirname(__FILE__)}/base_manifest.rb"

class DatabaseManifest < BaseManifest

<%- if postgresql? -%>
  configure :postgresql => build_postgresql_configuration
<%- elsif mysql? -%>
  configure :mysql => build_mysql_configuration
<%- end -%>
  recipe :standalone_database_stack
<%- if mysql? -%>
  recipe :mysql_tools
<%- end -%>
<%- if mmm? -%>
  recipe :mmm_agent
<%- end -%>

  configure :iptables => { :rules => build_database_iptables_rules }
  recipe    :iptables

  recipe :sysctl

  def scout_dependencies
<%- if mysql? -%>
    gem 'mysql'
<%- elsif postgresql? -%>
    gem 'pg', :ensure => :latest, :before => package('libpq-dev')

    psql "CREATE USER #{configuration[:scout][:postgresql][:user]} WITH PASSWORD '#{configuration[:scout][:postgresql][:password]}'",
      :alias    => "scout_postgresql_user",
      :unless   => psql_query('\\\\du') + "| grep #{configuration[:scout][:postgresql][:user]}",
      :require  => service('postgresql')
<%- else -%>
    # TODO database specific scout dependencies
<%- end -%>
  end
<%- if mmm? -%>

  # stub out rake environment. for various reasons, a db server isn't able to connect to itself
  def rails_rake_environment
    exec 'rake tasks', :command => 'true', :onlyif => 'false', :refreshonly => true
  end
<%- end -%>

end
