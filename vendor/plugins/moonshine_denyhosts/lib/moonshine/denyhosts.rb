module Moonshine
  module Denyhosts
    def denyhosts(options = {})
      options = denyhosts_default_configuration.merge(options.symbolize_keys).merge((configuration[:denyhosts] || {}).symbolize_keys)
      options[:smtp_subject] ||= "DenyHosts Report for #{Facter.fqdn}"

      package 'denyhosts',
        :ensure => :installed

      file '/etc/denyhosts.conf',
        :ensure => :present,
        :require => package('denyhosts'),
        :content => template(denyhosts_template_dir.join('denyhosts.conf.erb'), binding),
        :notify => service('denyhosts')
      file '/etc/init.d/denyhosts',
        :ensure => :present,
        :require => package('denyhosts'),
        :mode => '755',
        :content => template(denyhosts_template_dir.join('denyhosts.init'), binding),
        :notify => service('denyhosts')

      service 'denyhosts',
        :ensure => :running,
        :require => [ package('denyhosts'),
                      file('/etc/denyhosts.conf'),
                      file('/etc/init.d/denyhosts')]

      %w(allow deny).each do |k|
        entries = options[k.to_sym] || []
        if entries.any?
          file "/etc/hosts.#{k}",
            :ensure  => :present,
            :content => template(denyhosts_template_dir.join("hosts.#{k}.erb"), binding)
        end
      end
    end

    def denyhosts_default_configuration
      @denyhosts_default_configuration ||= YAML.load_file("#{File.dirname(__FILE__)}/denyhosts/default_configuration.yml").symbolize_keys
    end

    def denyhosts_template_dir
      Pathname.new(__FILE__).dirname.join('..', '..', 'templates')
    end

    def denyhosts_config_boolean(key, default = true)
      if key.nil?
        default ? 'YES' : 'NO'
      else
        ((!!key) == true) ? 'YES' : 'NO'
      end
    end
  end
end
