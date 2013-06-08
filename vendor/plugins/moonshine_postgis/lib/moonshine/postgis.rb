module Moonshine
  module Postgis
    def ldconfig
      exec 'ldconfig', :refreshonly => true
    end

    def geos
      package 'wget', :ensure => :installed
      exec 'download geos deb',
        :command => 'wget http://mirror.railsmachine.com/checkinstall/geos_3.3.3-1_amd64.deb -O /usr/local/src/geos_3.3.3-1_amd64.deb',
        :creates => '/usr/local/src/geos_3.3.3-1_amd64.deb',
        :require => package('wget')

      package 'geos',
        :ensure => :installed,
        :provider => :dpkg,
        :source => '/usr/local/src/geos_3.3.3-1_amd64.deb',
        :require => exec("download geos deb"),
        :notify => exec('ldconfig')
    end

    def gdal
      package 'wget', :ensure => :installed
      exec 'download gdal deb',
        :command => 'wget http://mirror.railsmachine.com/checkinstall/gdal_1.9.1-1_amd64.deb -O /usr/local/src/gdal_1.9.1-1_amd64.deb',
        :creates => '/usr/local/src/gdal_1.9.1-1_amd64.deb',
        :require => package('wget')

      package 'gdal',
        :ensure => :installed,
        :provider => :dpkg,
        :source => '/usr/local/src/gdal_1.9.1-1_amd64.deb',
        :require => [package('geos'), exec("download gdal deb")],
        :notify => exec('ldconfig')
    end

    def postgis
      package 'wget', :ensure => :installed
      exec 'download postgis deb',
        :command => "wget http://mirror.railsmachine.com/checkinstall/postgis-postgresql-#{postgresql_version}_2.0.1-1_amd64.deb -O /usr/local/src/postgis_2.0.1-1_amd64.deb",
        :creates => '/usr/local/src/postgis_2.0.1-1_amd64.deb',
        :require => package('wget')

      %w(libxslt1.1 libxslt1-dev libproj-dev libjson0-dev libxml2-dev).each do |p|
        package p, :ensure => :installed, :before => package('postgis')
        end

      package 'postgis',
        :ensure => :installed,
        :provider => :dpkg,
        :source => '/usr/local/src/postgis_2.0.1-1_amd64.deb',
        :require => [package('gdal'), exec('download postgis deb')],
        :notify => exec('ldconfig')
    end

    def template_postgis
      configure :postgresql => {:template_database => 'template_postgis'}

      # FIXME work in progress
      # encoding = "-E #{configuration[:postgresql][:encoding]}" if configuration[:postgresql][:encoding]
      encoding = '' 

      exec "createdb template_postgis",
        :command => "createdb template_postgis #{encoding}",
        :unless   => "/usr/bin/psql -l | grep template_postgis",
        :require => exec("postgresql_user"),
        :user => 'postgres'

      exec "psql postgis.sql into template_postgis",
        :command => "psql -d template_postgis -f /usr/share/postgresql/#{postgresql_version}/contrib/postgis-2.0/postgis.sql",
        :user => 'postgres',
        :require => exec("createdb template_postgis"),
        :subscribe => exec("createdb template_postgis"),
        :refreshonly => true 

      exec 'psql spatial_ref_sys.sql into template_postgis',
        :command => "psql -d template_postgis -f /usr/share/postgresql/#{postgresql_version}/contrib/postgis-2.0/spatial_ref_sys.sql",
        :user => 'postgres',
        :require => exec("psql postgis.sql into template_postgis"),
        :subscribe => exec("psql postgis.sql into template_postgis"),
        :before => exec("postgresql_database"),
        :refreshonly => true
    end

    def postgis_grant_workaround
      exec %Q{psql -d template_postgis  -c "grant select on geometry_columns,geography_columns,spatial_ref_sys to #{database_environment[:username]}"},
        :require => exec("postgresql_database"),
        :subscribe => exec("postgresql_database"),
        :user => 'postgres'
    end

    # Grant the database user specified in the current <tt>database_environment</tt>
    # permisson to access the database with the supplied password
    #
    # This is overrided from moonshine_postgres_9
    def postgresql_user
      psql "CREATE USER #{database_environment[:username]} WITH SUPERUSER PASSWORD '#{database_environment[:password]}'",
        :alias    => "postgresql_user",
        :unless   => psql_query('\\\\du') + "| grep \"\\b#{database_environment[:username]}\\b\"",
        :require  => service('postgresql')
    end

  end
end
