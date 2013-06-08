module Moonshine
  module Railsmachine
    def self.included(manifest)
      manifest.class_eval do
        extend ClassMethods
      end
    end

    module ClassMethods
      def railsmachine_template_dir
        @railsmachine_template_dir ||= Pathname.new(__FILE__).join('..', 'railsmachine', 'templates').expand_path.relative_path_from(Pathname.pwd)
      end

      def railsmachine_configuration
        YAML.load_file Pathname.new(__FILE__).join('..', 'railsmachine', 'configuration.yml')
      end

      # for moonshine_multi_server
      def convert_public_ip_to_private_ip(ip)
        case ip
        when /^216\.180\.248/
          ip.gsub(/216\.180\.248/, '10.0.4')
        when /^64\.22\.108/
          ip.gsub(/64\.22\.108/, '10.0.3')
        when /^64\.22\.127/
          ip.gsub(/64\.22\.127/, '10.0.2')
        when /^75\.127\.71/
          ip.gsub(/75\.127\.71/, '10.0.6')
        when /^207\.210\.122\./
          ip.gsub(/^207\.210\.122/, '10.0.0')
        else
          raise "Don't know how to get internal IP for #{ip}"
        end
      end
    end

    # Define options for this plugin via the <tt>configure</tt> method
    # in your application manifest:
    #
    #    configure(:railsmachine => {:foo => true})
    #
    # Moonshine will autoload plugins, just call the recipe(s) you need in your
    # manifests:
    #
    #    recipe :railsmachine
    def railsmachine(options = {})
      configure railsmachine_configuration

      recipe :railsmachine_scout_public_key
    end

    def railsmachine_scout_public_key
      # For convenience, we normalize the user scout will be running under.If nothing else, this will default to daemon.
      user = (configuration[:scout] && configuration[:scout][:user]) || configuration[:user] || 'daemon'

      file "/home/#{user}/.scout",
        :alias => '.scout',
        :ensure => :directory,
        :owner => user

      file "/home/#{user}/.scout/scout_rsa.pub",
        :ensure => :present,
        :content => template(railsmachine_template_dir.join('scout_rsa.pub')),
        :require => file('.scout'),
        :owner => user
    end

  end
end
