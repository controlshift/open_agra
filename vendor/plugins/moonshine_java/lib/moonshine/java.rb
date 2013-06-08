module Moonshine
  module Java

    def self.included(manifest)
      manifest.class_eval do
        extend ClassMethods
        configure :java => { :package => 'openjdk-6-jdk' }
      end
    end

    module ClassMethods
      def java_template_dir
        @java_template_dir ||= Pathname.new(__FILE__).join('..', '..', '..', 'templates').expand_path.relative_path_from(Pathname.pwd)
      end
    end

    def java(options = {})
      java_package = (options[:package] || configuration[:java][:package])

      file '/var/cache/preseeding',
        :ensure => :directory,
        :alias => 'preseeding directory'

      file '/var/cache/preseeding/java.seed',
        :ensure => :present,
        :content => template(java_template_dir.join('java.seed'), binding)

      package java_package,
        :ensure  => :installed,
        :alias   => 'java',
        :responsefile => '/var/cache/preseeding/java.seed',
        :require => file('/var/cache/preseeding/java.seed')

      java_alternative = case java_package
                         when "sun-java6-bin" then "java-6-sun"
                         when "openjdk-6-jdk" then "java-1.6.0-openjdk"
                         else java_package
                           raise "Don't know how to handle alternative #{java_package}"
                         end

      update_alternative_expected_display = case java_package
                                            when "sun-java6-bin" then java_alternative
                                            when "openjdk-6-jdk" then "java-6-openjdk"
                                            else
                                              raise "Don't know how to check alternative #{java_package}"
                                            end
      
      exec "update-java-alternatives --set #{java_alternative}",
        :require => package('java'),
        :alias   => 'update-java-alternatives',
        :unless =>  "update-alternatives --display java | grep -e #{update_alternative_expected_display}"
      
      recipe :canonical_source
    end

    def canonical_source
      append_if_no_such_line "deb http://archive.canonical.com/ubuntu lucid partner",
        "/etc/apt/sources.list",
        :before => exec('apt-get update')
    end

    private
    def append_if_no_such_line(line, file, options = {})
      hash = {
        :command => "/bin/echo '#{line}' >> #{file}", 
        :unless  => "/bin/grep -Fxqe '#{line}' #{file}" 
      }
      hash.merge!(options)

      exec "add #{line} to #{file}",
        hash
    end
  end
end
