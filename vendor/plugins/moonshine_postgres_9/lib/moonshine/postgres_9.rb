module Moonshine
  module Postgres9

    def self.included(manifest)
      manifest.class_eval do
        extend ClassMethods
      end
    end

    module ClassMethods

      def postgresql_primary?
        raise "FIXME please implement to determine if this server is the master"
      end

      def postgresql_standby?
        raise "FIXME please implement to determine if this server is the slaver"
      end

      # master of this master-replica pair
      def postgresql_primary_server
        raise "FIXME please implement to return a hash with :hostname, :ip, and :internal_ip of primary server"
      end

      # master of this master-replica pair
      def postgresql_standby_server
        raise "FIXME please implement to return a hash with :hostname, :ip, and :internal_ip of standby server"
      end
    end

    def postgresql_version
      (configuration[:postgresql] && configuration[:postgresql][:version]) || '9.0'
    end

    def postgresql_supports_custom_variable_classes?
      postgresql_version <= '9.1'
    end


    def postgresql_restart_on_change
      restart_on_change = configuration[:postgresql][:restart_on_change]
      restart_on_change = true if restart_on_change.nil? # treat nil as true, to be able to default
      restart_on_change
    end

    def postgresql_ppa
      package 'python-software-properties', :ensure => :installed

      configure(:postgresql => HashWithIndifferentAccess.new)
      exec 'add postgresql source list',
        :command => 'add-apt-repository ppa:pitti/postgresql',
        :creates => '/etc/apt/sources.list.d/pitti-postgresql-lucid.list',
        :require => package('python-software-properties')

      exec 'update sources',
        :command      => 'apt-get update',
        :subscribe    => exec('add postgresql source list'),
        :refreshonly  => true
    end

    def postgresql_client
      recipe :postgresql_ppa
      recipe :only_correct_postgres_version

      package 'libpq-dev',
        :ensure => :installed,
        :require => exec('update sources'),
        :before => exec('rails_gems')

      package "postgresql-client-#{postgresql_version}",
        :ensure => :installed,
        :require => exec('update sources'),
        :before => exec('rails_gems')
    end


    # Installs <tt>postgresql-9.x</tt> from apt and enables the <tt>postgresql</tt>
    # service.  Using a backports repo to get version 9.x:
    # https://launchpad.net/~pitti/+archive/postgresql 
    def postgresql_server(options = {})
      version = postgresql_version

      recipe :postgresql_client

      package "postgresql-#{version}",
      :ensure => :installed,
        :require => exec('update sources')        
      package "postgresql-contrib-#{version}",
      :ensure => :installed,
        :require => exec('update sources')        
      service 'postgresql',
        :ensure     => :running,
        :hasstatus  => true,
        :require    => package("postgresql-#{version}")

      notifies = if postgresql_restart_on_change
                   [service('postgresql')]
                 else
                   []
                 end
      # ensure the postgresql key is present on the configuration hash
      file "/etc/postgresql/#{version}/main/pg_hba.conf",
        :ensure  => :present,
        :content => template(File.join(File.dirname(__FILE__), '..', '..', 'templates', 'pg_hba.conf.erb'), binding),
        :require => package("postgresql-#{version}"),
        :mode    => '600',
        :owner   => 'postgres',
        :group   => 'postgres',
        :notify  => notifies
      file "/etc/postgresql/#{version}/main/postgresql.conf",
        :ensure  => :present,
        :content => template(File.join(File.dirname(__FILE__), '..', '..', 'templates', 'postgresql.conf.erb'), binding),
        :require => package("postgresql-#{version}"),
        :mode    => '600',
        :owner   => 'postgres',
        :group   => 'postgres',
        :notify  => notifies
    end

    # Install the <tt>pg</tt> rubygem and dependencies
    def postgresql_gem
      gem 'pg'
      gem 'postgres'
    end

    # Grant the database user specified in the current <tt>database_environment</tt>
    # permisson to access the database with the supplied password
    def postgresql_user
      psql "CREATE USER #{database_environment[:username]} WITH PASSWORD '#{database_environment[:password]}'",
        :alias    => "postgresql_user",
        :unless   => psql_query('\\\\du') + "| grep \"\\b#{database_environment[:username]}\\b\"",
        :require  => service('postgresql')
    end

    # Create the database from the current <tt>database_environment</tt>
    def postgresql_database
      # FIXME work in progress
      #encoding = "-E #{configuration[:postgresql][:encoding]}" if configuration[:postgresql][:encoding]
      encoding = ''
      template = "-T #{configuration[:postgresql][:template_database]}" if configuration[:postgresql][:template_database]

      exec "postgresql_database",
        :command  => "/usr/bin/createdb -O #{database_environment[:username]} #{encoding} #{template} #{database_environment[:database]}",
        :unless   => "/usr/bin/psql -l | grep #{database_environment[:database]}",
        :user     => 'postgres',
        :require  => exec('postgresql_user'),
        :before   => exec('rake tasks')#,
      # :notify   => exec('rails_bootstrap') # TODO make this configurable to work with multi_server
    end

    def postgresql_streaming_replication
      recipe :prune_pg_log
      recipe :wal_archive
      recipe :postgresql_ssh_access
      recipe :postgresql_replication_user

      if postgresql_primary?
        recipe :postgresql_replication_master
      elsif postgresql_standby?
        recipe :postgresql_replication_standby
      end
    end

    # Create a database user with replication priviledges
    def postgresql_replication_user
      replication_username = configuration[:postgresql][:replication_username] || "#{database_environment[:username]}_replication"
      raise "Missing configuration[:postgresql][:replication_password], please add and try again" unless configuration[:postgresql][:replication_password]

      psql "CREATE USER #{replication_username} WITH SUPERUSER ENCRYPTED PASSWORD '#{configuration[:postgresql][:replication_password]}'",
        :alias    => "postgresql_replication_user",
        :unless   => psql_query('\\\\du') + "| grep #{replication_username}",
        :require  => service('postgresql')
    end

    def postgresql_replication_master
      version = postgresql_version

      file "/var/lib/postgresql/#{postgresql_version}/main/pg_xlogarch",
        :ensure => :directory,
        :owner => 'postgres',
        :group => 'postgres'

      notifies = if postgresql_restart_on_change
                   [service('postgresql')]
                 else
                   []
                 end

      file '/var/lib/postgresql/recovery.conf',
        :require => package("postgresql-#{version}"),
        :ensure  => :absent,
        :notify  => notifies

      file "/var/lib/postgresql/#{version}/main/recovery.conf",
        :require => package("postgresql-#{version}"),
        :ensure => :absent,
        :notify  => notifies
    end

    def pgbouncer
      package 'pgbouncer', :ensure => :installed

      file '/etc/pgbouncer/userlist.txt',
        :ensure => :present,
        :require => package('pgbouncer'),
        :content => template(File.join(File.dirname(__FILE__), '..', '..', 'templates', 'userlist.txt.erb'))

      file '/etc/pgbouncer/pgbouncer.ini',
        :ensure => :present,
        :require => package('pgbouncer'),
        :content => template(File.join(File.dirname(__FILE__), '..', '..', 'templates', 'pgbouncer.ini.erb'))

      file '/etc/default/pgbouncer',
        :ensure => :present,
        :require => package('pgbouncer'),
        :content => 'START=1'

        service 'pgbouncer',
        :ensure => :running,
        :require => [
          file('/etc/pgbouncer/pgbouncer.ini'),
          file('/etc/pgbouncer/userlist.txt'),
          file('/etc/default/pgbouncer')
      ],
        :subscribe => [
          file('/etc/pgbouncer/pgbouncer.ini'),
          file('/etc/pgbouncer/userlist.txt'),
          file('/etc/default/pgbouncer')
      ]
    end

    def postgresql_ssh_access
      file '/var/lib/postgresql/.ssh',
        :ensure => :directory,
        :owner => 'postgres',
        :require => package("postgresql-#{postgresql_version}")

      exec %Q{ssh-keygen -f /var/lib/postgresql/.ssh/id_rsa -N ''},
        :user => 'postgres',
        :creates => '/var/lib/postgresql/.ssh/id_rsa',
        :require => [file('/var/lib/postgresql/.ssh'), package("postgresql-#{postgresql_version}")]

      (configuration[:postgresql][:public_ssh_keys] || {}).each do |hostname, key|
        ssh_authorized_key "postgres@#{hostname}",
          :type => 'ssh-rsa',
          :key => key,
          :user => 'postgres',
          :require => file('/var/lib/postgresql/.ssh')
      end
    end

    def wal_archive
      version = postgresql_version

      file '/var/lib/postgresql/wal_archive.sh',
        :require => package("postgresql-#{version}"),
        :content => template(File.join(File.dirname(__FILE__), '..', '..', 'templates', 'wal_archive.sh')),
        :ensure => :present,
        :mode => '755',
        :owner => 'postgres',
        :group => 'postgres'

      wal_dir = configuration[:postgresql][:wal_dir] || "/var/lib/postgresql/#{version}/main/pg_xlogarch"
      file wal_dir,
        :require => package("postgresql-#{version}"),
        :ensure => :directory,
        :owner => 'postgres',
        :group => 'postgres'

      file '/var/lib/postgresql/pitr-replication.conf',
        :require => package("postgresql-#{version}"),
        :content => template(File.join(File.dirname(__FILE__), '..', '..', 'templates', 'pitr-replication.conf.erb'), binding),
        :ensure => :present,
        :mode => '755',
        :owner => 'postgres',
        :group => 'postgres'
    end

    def prune_pg_log
      version = postgresql_version

      cron 'prune pg log',
        :command => "find /var/lib/postgresql/#{version}/main/pg_log -mtime +7 -delete",
      :user => 'root',
        :hour => '0',
        :minute => '10'
    end

    def postgresql_replication_standby
      version = postgresql_version
      notifies = if postgresql_restart_on_change
                   [service('postgresql')]
                 else
                   []
                 end
      file '/var/lib/postgresql/recovery.conf',
        :content => template(File.join(File.dirname(__FILE__), '..', '..', 'templates', 'recovery.conf.erb'), binding),
        :require => package("postgresql-#{version}"),
        :mode    => '600',
        :owner   => 'postgres',
        :group   => 'postgres',
        :notify  => notifies

      file "/var/lib/postgresql/#{version}/main/recovery.conf",
        :ensure => '/var/lib/postgresql/recovery.conf',
        :require => file('/var/lib/postgresql/recovery.conf')
    end

    # it's easy for other postgresql versions get installed. make sure they are uninstalled, and therefore not running
    def only_correct_postgres_version
      %w(8.4 9.0 9.1 9.2).each do |version|
        if version != postgresql_version.to_s # need to_s, because YAML may think it's a float
          package "postgresql-#{version}", :ensure => :absent
          package "postgresql-contrib-#{version}", :ensure => :absent
          package "postgresql-client-#{version}", :ensure => :absent
        end
      end
    end

    private

    def psql(query, options = {})
      name = options.delete(:alias) || "psql #{query}"
      hash = {
        :command => psql_query(query),
        :user => 'postgres'
      }.merge(options)
      exec(name,hash)
    end

    def psql_query(sql, options = {})
      if options && options[:dbname]
        dbname = "--dbname #{options[:dbname]}"
      end

      "/usr/bin/psql -c \"#{sql}\" #{dbname}"
    end
  end
end
