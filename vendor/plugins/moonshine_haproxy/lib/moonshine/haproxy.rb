module Moonshine
  module Haproxy
    # Define options for this plugin via the <tt>configure</tt> method
    # in your application manifest:
    #
    #    configure(:haproxy => {:foo => true})
    #
    # Moonshine will autoload plugins, just call the recipe(s) you need in your
    # manifests:
    #
    #    recipe :haproxy
    def haproxy(options = {})
      # define the recipe
      # options specified with the configure method will be
      # automatically available here in the options hash.
      #    options[:foo]   # => true

      options = HashWithIndifferentAccess.new({
        :ssl     => false,
        :version => '1.4.15'
      }.merge(options))
      options[:major_version] = options[:version].split('.')[0..1].join('.')

      package 'haproxy', :ensure => :absent
      package 'wget', :ensure => :installed
      package 'libpcre3-dev', :ensure => :installed
      exec 'download haproxy',
        :command => "wget http://haproxy.1wt.eu/download/#{options[:major_version]}/src/haproxy-#{options[:version]}.tar.gz",
        :require => package('wget'),
        :cwd     => '/usr/local/src',
        :creates => "/usr/local/src/haproxy-#{options[:version]}.tar.gz"
      exec 'untar haproxy',
        :command => "tar xzvf haproxy-#{options[:version]}.tar.gz",
        :require => exec('download haproxy'),
        :cwd     => '/usr/local/src',
        :creates => "/usr/local/src/haproxy-#{options[:version]}"
      exec 'compile haproxy',
        :command => 'make TARGET=linux26 USE_PCRE=1 USE_STATIC_PCRE=1 USE_LINUX_SPLICE=1 USE_REGPARM=1',
        :require => [exec('untar haproxy'), package('libpcre3-dev')],
        :cwd     => "/usr/local/src/haproxy-#{options[:version]}",
        :creates => "/usr/local/src/haproxy-#{options[:version]}/haproxy"
      package 'haproxy',
        :ensure   => :absent,
        :require   => exec('compile haproxy')
      exec 'install haproxy',
        :command => "sudo make install",
        :timeout => 0,
        :require => package('haproxy'),
        :cwd     => "/usr/local/src/haproxy-#{options[:version]}",
        :unless => "test -f /usr/local/sbin/haproxy && /usr/local/sbin/haproxy -v | grep 'version #{options[:version]} '"

      file '/etc/haproxy/', :ensure => :directory
      haproxy_cfg_template = options[:haproxy_cfg_template] || File.join(File.dirname(__FILE__), '..', '..', 'templates', 'haproxy.cfg.erb')
      
      errorfiles = {}
      error_code_descriptions = {
                                  '400' => "Bad Request",
                                  '403' => "Forbidden",
                                  '408' => "Request Timeout",
                                  '500' => "Internal Server Error",
                                  '503' => "Service Unavailable",
                                  '504' => "Gateway Timeout"
                                } 
      error_code_descriptions.each do |status,status_description|
        error_file = rails_root.join("public/#{status}.html")
        if error_file.exist?
          errorfiles[status] = "/etc/haproxy/#{status}.http"
          file "/etc/haproxy/#{status}.http",
            :ensure => :present,
            :before => file('/etc/haproxy/haproxy.cfg'),
            :notify => service('haproxy'),
            :content => <<-END
HTTP/1.0 #{status} #{status_description}
Cache-Control: no-cache
Connection: close
Content-Type: text/html

#{error_file.read}          
END
        end
      end
      
      configure(:haproxy => {:errorfiles => errorfiles})

      file '/etc/haproxy/haproxy.cfg',
        :ensure => :present,
        :notify => service('haproxy'),
        :content => template(haproxy_cfg_template, binding)
      file '/etc/default/haproxy',
        :ensure => :present,
        :notify => service('haproxy'),
        :content => "ENABLED=1\n"

      file '/etc/init.d/haproxy',
        :ensure  => :present,
        :mode    => '755',
        :content => template(File.join(File.dirname(__FILE__), '..', '..', 'templates', 'init.d'), binding)
      service 'haproxy',
        :ensure => :running,
        :enable => true,
        :require => [package('haproxy'), exec('install haproxy'), file('/etc/init.d/haproxy')]

      service 'rsyslog',
        :ensure => :running

      file '/etc/rsyslog.d/99-haproxy.conf',
        :ensure => :absent,
        :notify => service('rsyslog')
      file '/etc/rsyslog.d/40-haproxy.conf',
        :ensure => :present,
        :notify => service('rsyslog'),
        :content => template(File.join(File.dirname(__FILE__), '..', '..', 'templates', 'haproxy.rsyslog.conf'))

      logrotate '/var/log/haproxy*.log',
        :options => %w(daily missingok notifempty compress delaycompress sharedscripts),
        :postrotate => 'reload rsyslog >/dev/null 2>&1 || true'
      file "/etc/logrotate.d/varloghaproxy.conf", :ensure => :absent

      ssl_configuration = configuration[:ssl] || options[:ssl] || {}
      if ssl_configuration.any?
        recipe :apache_server

        a2enmod 'proxy'
        a2enmod 'proxy_http'
        a2enmod 'proxy_connect'
        a2enmod 'headers'
        a2enmod 'ssl'

        file "/etc/apache2/",
          :ensure => :directory,
          :mode => '755'

        file "/etc/apache2/apache2.conf",
          :alias => 'apache_conf',
          :ensure => :present,
          :content => template(File.join(File.dirname(__FILE__), '..', '..', 'templates', 'haproxy-apache2.conf'), binding),
          :mode => '644',
          :notify => service("apache2")

        file "/etc/apache2/ssl/",
          :ensure => :directory,
          :mode => '755'

        ssl_cert_files = [
          ssl_configuration[:certificate_file],
          ssl_configuration[:certificate_key_file],
          ssl_configuration[:certificate_chain_file]
        ].compact
        ssl_cert_files.each do |cert_file_path|
          file cert_file_path,
            :ensure => :present,
            :mode => '644',
            :notify => service("apache2")
        end

        file "/etc/apache2/sites-available/haproxy",
          :alias => 'haproxy_vhost',
          :ensure => :present,
          :content => template(File.join(File.dirname(__FILE__), '..', '..', 'templates', 'haproxy.vhost.erb'), binding),
          :notify => service("apache2"),
          :require => ssl_cert_files.map { |f| file(f) }

        file "/etc/apache2/ports.conf",
          :ensure => :present,
          :content => template(File.join(File.dirname(__FILE__), '..', '..', 'templates', 'haproxy-ports.conf'), binding),
          :mode => '644',
          :notify => service("apache2")

        a2dissite "000-default"

        file "/etc/apache2/sites-available/default",
          :alias => 'default_vhost',
          :ensure => :present,
          :content => template(File.join(File.dirname(__FILE__), '..', '..', 'templates', 'haproxy-default'), binding),
          :mode => '644',
          :notify => service("apache2")

        file "/etc/apache2/envvars",
          :alias => 'apache_envvars',
          :ensure => :present,
          :content => template(File.join(File.dirname(__FILE__), '..', '..', 'templates', 'haproxy-envvars'), binding),
          :mode => '644',
          :notify => service("apache2")

        file '/etc/apache2/sites-enabled/zzz_default', :ensure => '/etc/apache2/sites-available/default'

        a2ensite "haproxy", :require => file('haproxy_vhost')
      end
    end
    
  end
end