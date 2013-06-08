require 'resolv'
module Moonshine
  module MultiServer

    def self.included(manifest)
      manifest.class_eval do
        extend ClassMethods
        servers_helpers = configuration.keys.select do |key|
          key.to_s =~ /_servers$/
        end

        servers_helpers.each do |helper|
          eval %Q{
            def self.#{helper}
              @#{helper} ||= servers_array_to_servers_hash_with_info(configuration[:#{helper}] || [])
            end
          }
        end

        server_helpers = configuration.keys.select do |key|
          key.to_s =~ /_server$/
        end

        server_helpers.each do |helper|
          eval %Q{
            def self.#{helper}
              @#{helper} ||= servers_array_to_servers_hash_with_info(configuration[:#{helper}] || []).first
            end
          }
        end

      end
    end

    def default_web_stack
      recipe :apache_server
    end

    def standalone_web_stack
      recipe :default_web_stack
      recipe :default_system_config
      recipe :non_rails_recipes
    end

    def standalone_haproxy_stack
      recipe :default_system_config
      recipe :non_rails_recipes

      recipe :haproxy
      recipe :heartbeat
      recipe :iptables
    end

    def standalone_memcached_stack
      recipe :memcached
      recipe :iptables

      recipe :default_system_config
      recipe :non_rails_recipes
    end

    def standalone_redis_stack
      recipe :non_rails_recipes
      recipe :default_system_config

      recipe :redis
      recipe :iptables
      recipe :sysctl
    end

    def standalone_sphinx_stack
      recipe :sphinx
      recipe :iptables
      recipe :sysctl

      recipe :rails_recipes
    end

    def standalone_sunspot_stack
      recipe :java
      recipe :iptables
      recipe :default_system_config
      recipe :rails_recipes
    end

    def standalone_worker_stack
      recipe :rails_recipes
      recipe :default_system_config
      recipe :iptables
    end
    
    def default_database_stack
      case database_environment[:adapter]
      when 'mysql', 'mysql2'
        recipe :mysql_server, :mysql_database, :mysql_user, :mysql_fixup_debian_start
      when 'postgresql', 'postgis'
        recipe :postgresql_server, :postgresql_user, :postgresql_database
      when 'sqlite', 'sqlite3'
        recipe :sqlite3
      end
    end
    
    def standalone_database_stack
      # Create the database from the current <tt>database_environment</tt>
      def mysql_database
        exec "mysql_database",
          :command => mysql_query("create database #{database_environment[:database]};"),
          :unless => mysql_query("show create database #{database_environment[:database]};"),
          :require => service('mysql')
      end

      def mysql_user
        ips = configuration[:mysql][:allowed_hosts] || []
        allowed_hosts = ips || []
        allowed_hosts << 'localhost'
        allowed_hosts.each do |host|
          grant =<<EOF
GRANT ALL PRIVILEGES
ON #{database_environment[:database]}.*
TO #{database_environment[:username]}@#{host}
IDENTIFIED BY \\"#{database_environment[:password]}\\";
FLUSH PRIVILEGES;
EOF
          exec "#{host}_mysql_user",
            :command => mysql_query(grant),
            :unless  => "mysql -u root -e ' select User from user where Host = \"#{host}\"' mysql | grep #{database_environment[:username]}",
            :require => exec('mysql_database')
        end
      end

      # placeholder, this will happen on the app server
      def rails_bootstrap
        exec 'rails_bootstrap', :command => 'true', :refreshonly => true, :unless => 'false'
      end

      recipe :default_database_stack
      recipe :default_system_config
      recipe :rails_recipes
      recipe :rails_bootstrap
    end

    def default_application_stack
      recipe :default_web_stack
      recipe :passenger_gem, :passenger_configure_gem_path, :passenger_apache_module, :passenger_site
      recipe :rails_recipes, :rails_database_recipes

      if precompile_asset_pipeline?
        recipe :rails_asset_pipeline
      end
    end

    def standalone_application_stack
      recipe :default_application_stack
      recipe :default_system_config      
      recipe :iptables
    end

    def default_system_config
      recipe :ntp, :time_zone, :postfix, :cron_packages, :motd, :security_updates, :apt_sources
    end

    def default_stack
      recipe :default_web_stack
      recipe :default_database_stack
      recipe :default_application_stack
      recipe :default_system_config
    end

    def rails_recipes
      case database_environment[:adapter]
      when 'mysql', 'mysql2'
        recipe :mysql_gem
      when 'postgresql'
        recipe :postgresql_gem
      end
      recipe :rails_rake_environment, :rails_gems, :rails_directories, :rails_logrotate
    end

    def rails_database_recipes
      recipe :rails_bootstrap, :rails_migrations
    end

    def non_rails_recipes
      # Set up gemrc and the 'gem' package helper, but not Rails application gems.
      def gemrc
        exec 'rails_gems',
          :command => 'true',
          :onlyif => 'false',
          :refreshonly => true

        gemfile_path = rails_root.join('Gemfile')
        if gemfile_path.exist?
          exec 'bundle install',
            :command => 'true',
            :onlyif => 'false', 
            :refreshonly => true,
            :before => exec('rails_gems')
        end

        gemrc = {
          :verbose => true,
          :gem => "--no-ri --no-rdoc",
          :update_sources => true,
          :sources => [ 'http://rubygems.org' ]
        }
        gemrc.merge!(configuration[:rubygems]) if configuration[:rubygems]
        file '/etc/gemrc',
          :ensure   => :present,
          :mode     => '744',
          :owner    => 'root',
          :group    => 'root',
          :content  => gemrc.to_yaml
      end

      def non_rails_rake_environment
        package 'rake', :provider => :gem, :ensure => :installed
        exec 'rake tasks', :command => 'true', :onlyif => 'false', :refreshonly => true
      end
      recipe :non_rails_rake_environment, :gemrc
      recipe :rails_directories, :rails_logrotate
    end
  end


  module ClassMethods
    def servers_array_to_servers_hash_with_info(servers)
      servers.map do |hostname|
        ip = Resolv.getaddress hostname
        {    
          :hostname => hostname,
          :ip => ip,
          :internal_ip => convert_public_ip_to_private_ip(ip)
        }
      end
    end

    def convert_public_ip_to_private_ip(ip)
      ip
    end
  end


end
