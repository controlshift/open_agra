class MoonshineMultiServerGenerator < Rails::Generator::Base

  KNOWN_ROLES = %w(application haproxy database redis memcached mongodb dj sphinx)
  KNOWN_DATABASES = %w(postgresql mysql)

  default_options :database => 'mysql'
  default_options :mmm => false

  def initialize(runtime_args, runtime_options = {})
    super
    @roles = normalize_roles(runtime_args.dup)
  end

  def manifest
    recorded_session = record do |m|
      m.directory 'app/manifests'

      m.template 'base_manifest.rb', 'app/manifests/base_manifest.rb'

      m.directory 'app/manifests/lib'
      m.template 'configuration_builders.rb', 'app/manifests/lib/configuration_builders.rb'

      @roles.each do |role|

        template_file = if KNOWN_ROLES.include?(role)
                          "#{role}_manifest.rb"
                        else
                          'role_manifest.rb'
                        end

        m.template template_file, "app/manifests/#{role}_manifest.rb", :assigns => {:role => role}
      end

    end
  end

  protected

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
        false
      end

      def mysql?
        options[:database] == 'mysql'
      end

      def mmm?
        options[:mmm]
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

  protected

      def add_options!(opt)
        opt.separator ''
        opt.separator 'Options:'
        opt.on("--database DATABASE",
                                  "(sql) database to use for the application") { |database| options[:database] = database }

        opt.on("--mmm",
                                  "setup mmm for high availability mysql") {  options[:mmm] = true }
      end
end
