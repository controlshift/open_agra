module ConfigurationBuilders

  def self.included(base)
    base.extend(ClassMethods)
  end 

  module ClassMethods
    def build_base_iptables_rules
      [
        '-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT',
        '-A INPUT -p icmp -j ACCEPT',
        '-A INPUT -p tcp -m tcp --dport 22 -j ACCEPT',
        '-A INPUT -s 127.0.0.1 -j ACCEPT'
      ]
    end

    def build_haproxy_configuration
      default_backend = "#{configuration[:application]}_backend"

      username, password = (configuration[:apache] && configuration[:apache][:users] && configuration[:apache][:users].first)
      basic_authorization =  if username && password
                               Base64.encode64("#{username}:#{password}")
                             end

      httpchk_headers = [
        "Host: #{configuration[:domain]}",
        "X-Forwarded-For: #{configuration[:domain]}"
      ]
      username, password = (configuration[:apache] && configuration[:apache][:users] && configuration[:apache][:users].first)
      if username && password
       httpchk_headers << "Authorization: Basic #{Base64.encode64("#{username}:#{password}")}"
      end

      apps_backend = {
        :name => default_backend,
        :balance => 'roundrobin',
        :servers => [],
        :options => [
          "option httpchk GET /pulse HTTP/1.1\\r\\n#{httpchk_headers.join("\\r\\n").gsub(/ /, "\\ ")}"
        ]
      }

      apps_backend[:servers] = application_servers.map do |server|
        url = "#{server[:internal_ip]}:#{configuration[:apache][:port] || 80}"
        name = server[:hostname].split('.').first
        {
          :url => url,
          :name => name,
          :maxconn => 1000,
          :weight => 28,
          :options => [
            'check',
            'inter 20000',
            'fastinter 500',
            'downinter 500',
            'fall 1'
          ]
        }
      end

      {
        :default_backend => default_backend,
        :backends => [apps_backend]
      }
    end

    def build_heartbeat_configuration
      nodes = haproxy_servers.map do |server|
        [server[:hostname], server[:internal_ip]]
      end

      primary_node = nodes.first.first

      public_resources = (configuration[:web_ha_ips] || []).map do |ip|
        "IPaddr::#{ip}/24/eth0"
      end

      private_resources = (configuration[:web_private_ha_ips] || []).map do |ip|
        "IPaddr::#{ip}/24/eth1"
      end

      # FIXME private resources can cause heartbeat problems.
      # in particular, if the web server's IP is in the same subnet as the
      # private resource, bringing up the private resource adds routing which
      # messes with heartbeat's ability to detect the other nodes upedness,
      # leading to split brain
      resources = public_resources + private_resources

      # following recommendations at http://linux-ha.org/wiki/FAQ#Heavy_Load
      deadtime = 60
      warntime = deadtime / 2
      initdead = deadtime * 2

      {
        :nodes => nodes,
        :resources => {
          primary_node => resources
        },
        :deadtime => deadtime,
        :warntime => warntime,
        :initdead => initdead
      }
    end

    def build_ssl_configuration
      {}
    end

    def build_web_iptables_configuration
      rules = build_base_iptables_rules

      # full access between web servers
      haproxy_servers.each do |server|
        rules << "-A INPUT -s #{server[:internal_ip]} -j ACCEPT"
      end

      # open access to http and https
      [80, 443].each do |port|
        rules << "-A INPUT -p tcp -m tcp --dport #{port} -j ACCEPT"
      end

      {:rules => rules}
    end 

    def build_app_iptables_configuration
      rules = build_base_iptables_rules
      # open access to http and https
      [80, 443].each do |port|
        rules << "-A INPUT -p tcp -m tcp --dport #{port} -j ACCEPT"
      end

      {:rules => rules}
    end

    def build_worker_iptables_configuration
      rules = build_base_iptables_rules

      {:rules => rules}
    end

    def postgresql_replica_pair
      configuration[:database_primary_standby_pairs].detect {|primary, standby| primary == Facter.fqdn || standby == Facter.fqdn}
    end

    def postgresql_primary?
      primary, _ = postgresql_replica_pair()

      primary == Facter.fqdn
    end

    def postgresql_standby?
      _, standby = postgresql_replica_pair()

      standby == Facter.fqdn
    end

    # master of this master-replica pair
    def postgresql_primary_server
      primary, _ = postgresql_replica_pair()

      database_servers.find {|server| server[:hostname] == primary }
    end

    # master of this master-replica pair
    def postgresql_standby_server
      _, standby = postgresql_replica_pair()
      database_servers.find {|server| server[:hostname] == standby }
    end

    def build_database_iptables_rules
      rules = build_base_iptables_rules
      servers_with_rails_env.each do |server|
        rules << "-A INPUT -s #{server[:internal_ip]} -p tcp -m tcp --dport 5432 -j ACCEPT"
      end

      rules
    end

    def build_postgresql_configuration
      { 
        :listen_addresses => ['127.0.0.1', Facter.ipaddress_eth1]
      }
    end

    def build_sunspot_iptables_configuration
      rules = build_base_iptables_rules

      servers_with_rails_env.each do |server|
          rules << "-A INPUT -s #{server[:internal_ip]} -p tcp -m tcp --dport 8983 -j ACCEPT"
      end

      {:rules => rules}
    end  

    def build_redis_iptables_configuration
      rules = build_base_iptables_rules

      (servers_with_rails_env + redis_servers).each do |server|
          rules << "-A INPUT -s #{server[:internal_ip]} -p tcp -m tcp --dport 6379 -j ACCEPT"
      end

      {:rules => rules}
    end  

    def redis_master_slave_pair
      configuration[:redis_master_slave_pairs].detect {|primary, standby| primary == Facter.fqdn || standby == Facter.fqdn}
    end

    def redis_primary?
      primary, _ = redis_master_slave_pair()
      primary == Facter.fqdn
    end

    def redis_slave?
      _, slave = redis_master_slave_pair()
      slave == Facter.fqdn
    end

    def master_redis_server
      primary, _ = redis_master_slave_pair()
      redis_servers.find {|server| server[:hostname] == primary }
    end

    def slave_redis_server
      _, slave = redis_master_slave_pair()
      redis_servers.find {|server| server[:hostname] == slave }
    end


    def build_redis_configuration
      slave_of = case Facter.ipaddress_eth1
                 when master_redis_server[:internal_ip]
                   nil
                 when slave_redis_server[:internal_ip]
                   "slaveof #{master_redis_server[:internal_ip]} 6379"
                 else
                   raise "don't know master for #{Facter.hostname} (ip was #{Facter.ipaddress_eth1}, but only know about #{master_redis_server.inspect} and #{slave_redis_server.inspect})"
                 end

      slaves = [slave_of].compact
      {:slaves => slaves}
    end

    def build_memcached_configuration
      {:listen_address => '0.0.0.0'}
    end

    def build_memcached_iptables_configuration
      rules = build_base_iptables_rules

      (servers_with_rails_env + memcached_servers).each do |server|
        rules << "-A INPUT -s #{server[:internal_ip]} -p tcp -m tcp --dport 11211 -j ACCEPT"
      end

      {:rules => rules}
    end

     def servers_with_rails_env
       (application_servers + database_servers + worker_servers + sunspot_servers)
     end
 
  end
end
