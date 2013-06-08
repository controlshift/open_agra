module Moonshine
  module Generators
    class MultiServerGenerator < Rails::Generators::Base
      KNOWN_ROLES = %w(application haproxy database redis memcached mongodb dj sphinx)
      KNOWN_DATABASES = %w(postgresql mysql)

      desc Pathname.new(__FILE__).dirname.join('..', '..', '..', '..', 'generators', 'moonshine_multi_server', 'USAGE').read

      class_option :database, :default => 'mysql', :desc => '(sql) database to use for the application'
      argument :roles, :type => :array, :defaults => %w(application haproxy database)

      def self.source_root
        @_moonshine_source_root ||= Pathname.new(__FILE__).dirname.join('..', '..', '..', '..', 'generators', 'moonshine_multi_server', 'templates')
      end

      def manifest
        @roles = normalize_roles(@roles)

        plugin 'moonshine', :git => 'git://github.com/railsmachine/moonshine.git'
        generate 'moonshine', "--multistage", "--skip-manifest"


        servers_for_moonshine_yml = @roles.map do |role|
"""

:#{role}_servers:
- FIXME with list of servers"""
        end.join("")

        inject_into_file 'config/moonshine/staging.yml', servers_for_moonshine_yml, :after => "#  - assets2.staging.yourapp.com"
        inject_into_file 'config/moonshine/production.yml', servers_for_moonshine_yml, :after => "#  - assets2.yourapp.com"

        template 'base_manifest.rb', 'app/manifests/base_manifest.rb'

        template 'configuration_builders.rb', 'app/manifests/lib/configuration_builders.rb'

        @roles.each do |role|
          template_file = if KNOWN_ROLES.include?(role)
                            "#{role}_manifest.rb"
                          elsif role
                            'role_manifest.rb'
                          else
                            raise "Nil role :("
                          end
          self.role = role
          template template_file, "app/manifests/#{role}_manifest.rb"
        end

        plugin 'moonshine_scout', :git => 'git://github.com/railsmachine/moonshine_scout.git'
        plugin 'moonshine_denyhosts', :git => 'git://github.com/railsmachine/moonshine_denyhosts.git'
        plugin 'moonshine_ssh', :git => 'git://github.com/railsmachine/moonshine_ssh.git'

        if mongodb?
          plugin 'moonshine_mongodb', :git => 'git://github.com/railsmachine/moonshine_mongodb.git'
        end

        if haproxy?
          plugin 'moonshine_haproxy', :git => 'git://github.com/railsmachine/moonshine_haproxy.git'
          plugin 'moonshine_heartbeat', :git => 'git://github.com/railsmachine/moonshine_heartbeat.git'
        end

        if iptables?
          plugin 'moonshine_iptables', :git => 'git://github.com/railsmachine/moonshine_iptables.git'
        end

        if redis?
          plugin 'moonshine_redis', :git => 'git://github.com/railsmachine/moonshine_redis.git'
        end

        if sysctl?
          plugin 'moonshine_sysctl', :git => 'git://github.com/railsmachine/moonshine_sysctl.git'
        end

        if memcached?
          plugin 'moonshine_memcached', :git => 'git://github.com/railsmachine/moonshine_memcached.git'
        end

        if asset_pipeline?
          plugin 'moonshine_nodejs', :git => 'git://github.com/railsmachine/moonshine_nodejs.git'
        end

        if postgresql?
          plugin 'moonshine_postgres_9', :git => 'git@github.com:railsmachine/moonshine_postgres_9.git'
        end

      end

      protected

      # super hax to make compatible with rails 2 generator, so we can set it in the role above, and have access to 'role'
      attr_accessor :role

      # FIXME metaprogram using KNOWN_ROLES?

      def app?
        @roles.include?('application')
      end

      def haproxy?
        @roles.include?('haproxy')
      end

      def database?
        @roles.include?('database')
      end

      def redis?
        @roles.include?('redis')
      end

      def memcached?
        @roles.include?('memcached')
      end

      def sphinx?
        @roles.include?('sphinx')
      end

      def mongodb?
        @roles.include?('mongodb')
      end

      def dj?
        @roles.include?('dj')
      end

      def asset_pipeline?
        Rails.version >= '3.1' && Rails.root.join('app/assets').directory?
      end

      def mysql?
        options[:database] == 'mysql'
      end

      def postgresql?
        options[:database] == 'postgresql'
      end

      def iptables?
        haproxy? || mongodb? || sphinx? || redis? || memcached? || database?
      end

      def worker?
        dj? || @roles.include?('worker')
      end

      def sysctl?
        redis? || database? || sphinx?
      end

      def servers_with_rails_env
        rails_roles = []
        rails_roles << 'application' if app?
        rails_roles << 'database' if database?
        rails_roles << 'sphinx' if sphinx?
        rails_roles << 'worker' if worker?

        rails_roles.map {|role| "#{role}_servers" }
      end

      def normalize_roles(roles)
        roles.map do |role|
          case role
          when 'db'
            'database'
          when 'app' 
            'application'
          when 'web' 
            'haproxy'
          else
            role
          end
        end.compact.sort
      end

      def role=(role)
        @role = role
      end

      def role
        @role
      end

    end
  end
end
