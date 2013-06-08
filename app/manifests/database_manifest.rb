require "#{File.dirname(__FILE__)}/base_manifest.rb"

class DatabaseManifest < BaseManifest

  configure :postgresql => build_postgresql_configuration

  # specify template_postgis first to make sure database is created from that template
  recipe :template_postgis
  recipe :postgis_grant_workaround if postgresql_primary?

  recipe :standalone_database_stack
  recipe :postgresql_hstore_extension
  recipe :postgresql_streaming_replication

  configure :iptables => { :rules => build_database_iptables_rules }
  recipe    :iptables

  recipe :sysctl

  recipe :ldconfig
  recipe :gdal
  recipe :geos
  recipe :postgis
  recipe :kmeans_postgresql



  def scout_dependencies
    gem 'pg', :ensure => :latest, :before => package('libpq-dev')

    psql "CREATE USER #{configuration[:scout][:postgresql][:user]} WITH PASSWORD '#{configuration[:scout][:postgresql][:password]}'",
      :alias    => "scout_postgresql_user",
      :unless   => psql_query('\\\\du') + "| grep #{configuration[:scout][:postgresql][:user]}",
      :require  => service('postgresql')
  end

  def postgresql_hstore_extension
    psql "CREATE EXTENSION HSTORE;",
      :require => service('postgresql'),
      :unless => psql_query('\\\\dx') + "| grep -i hstore"
  end

  def kmeans_postgresql
    package 'wget', :ensure => :installed
    package "postgresql-server-dev-#{postgresql_version}", :ensure => :installed
    exec 'download kmeans-postgresql tarball',
      :command => 'wget https://github.com/umitanuki/kmeans-postgresql/archive/v1.1.0.tar.gz -O /usr/local/src/kmeans-postgresql-1.1.0.tar.gz',
      :creates => '/usr/local/src/kmeans-postgresql-1.1.0.tar.gz',
      :require => package('wget')
    
    exec 'kmeans_postgresql',
      :command => "/bin/bash -c \"" + [
        'cd /tmp',
        'sudo rm -rf kmeans-postgresql-1.1.0',
        'tar xzf /usr/local/src/kmeans-postgresql-1.1.0.tar.gz',
        'cd kmeans-postgresql-1.1.0',
        'make',
        'sudo make install'].join(' && ') + "\"",
      :creates => "/usr/share/postgresql/#{postgresql_version}/extension/kmeans--1.1.0.sql",
      :require => [package("postgresql-server-dev-#{postgresql_version}"), exec('download kmeans-postgresql tarball')]
     
    exec 'load kmeans functions',
      :command => "psql --dbname #{database_environment[:database]} -f /usr/share/postgresql/#{postgresql_version}/extension/kmeans--1.1.0.sql",
      :unless => psql_query("SELECT COUNT(*) FROM pg_proc WHERE proname='kmeans'", :dbname => database_environment[:database]) + "| grep \"^ \\+2\"",
      :user => 'postgres',
      :require => [exec('kmeans_postgresql'), exec('postgresql_database')]
  end
end
