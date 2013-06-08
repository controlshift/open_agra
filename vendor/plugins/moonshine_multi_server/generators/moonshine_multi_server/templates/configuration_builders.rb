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
<%- if haproxy? -%>

    def build_haproxy_configuration
      default_backend = "#{configuration[:application]}_backend"

      apps_backend = {
        :name => default_backend,
        :balance => 'roundrobin',
        :servers => [],
        :options => [
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
        :initdead => initdead,
        :interface => 'eth1'
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
<%- end -%>
<%- if app? -%>

    def build_app_iptables_configuration
      rules = build_base_iptables_rules
      # open access to http and https
      [80, 443].each do |port|
        rules << "-A INPUT -p tcp -m tcp --dport #{port} -j ACCEPT"
      end 

      {:rules => rules}
    end 
<%- end -%>
<%- if worker? -%>

    def build_worker_iptables_configuration
      rules = build_base_iptables_rules

      {:rules => rules}
    end 
<%- end -%>
<%- if database? -%>

    def build_database_iptables_rules
      rules = build_base_iptables_rules
      servers_with_rails_env.each do |server|
<%- if mysql? -%>
        rules << "-A INPUT -s #{server[:internal_ip]} -p tcp -m tcp --dport 3306 -j ACCEPT"
<%- elsif postgresql? -%>
        rules << "-A INPUT -s #{server[:internal_ip]} -p tcp -m tcp --dport 5432 -j ACCEPT"
<%- else -%>
        raise 'FIXME needs implementation to open up database port'
<%- end -%>
      end

  <%- if mmm? -%>
      # mmm connection to mysql
      rules << "-A INPUT -s #{mmm_monitor_server[:internal_ip]} -p tcp -m tcp --dport 3306 -j ACCEPT"
      # mmm connection to the agent
      rules << "-A INPUT -s #{mmm_monitor_server[:internal_ip]} -p tcp -m tcp --dport 9989 -j ACCEPT"

  <%- end -%>
      rules
    end
<%- if postgresql? -%>
    def build_postgresql_configuration
      {
        :listen_addresses => ['127.0.0.1', Facter.ipaddress_eth1],
        :version => "9.2"
      }
    end
<%- end -%>
<%- if mysql? %>
    def build_mysql_configuration
      server_id = if Facter.hostname =~ /^mysql(\d+)/  || Facter.hostname =~ /^db(\d+)/ 
                    $1.to_i
                  else
                    1
                  end
      extra = """
bind-address = 0.0.0.0
read-only
"""
      allowed_hosts = servers_with_rails_env.map {|server| server[:internal_ip] }
      allowed_replication_hosts = database_servers.map {|server| server[:internal_ip] }

      {
        :mmm => {
          :db1 => database_servers[0][:internal_ip],
          :db2 => database_servers[1][:internal_ip],
          :monitor => mmm_monitor_server[:internal_ip],
          :bind_address_already_configured => true,
          :allowed_replication_hosts => allowed_replication_hosts
        },
        :master_bind_address => '0.0.0.0',
        :extra => extra,
        :server_id => server_id,
        :allowed_hosts => allowed_hosts
      }
    end

    def build_mysql_allowed_hosts
      servers_with_rails_env.map do |host|
        host[:internal_ip]
      end
    end

<%- end -%>
<%- end -%>
<%- if redis? -%>

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
<%- end -%>
<%- if memcached? -%>

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
<%- end -%>
<%- if sphinx? -%>

    def build_sphinx_iptables_configuration
      rules = build_base_iptables_rules

      servers_with_rails_env.each do |server|
        rules << "-A INPUT -s #{server[:internal_ip]}/32 -p tcp -m tcp --dport 9312 -j ACCEPT"
      end

      {:rules => rules}
    end

    def build_sphinx_server_configuration
      {:extra => {:address => '0.0.0.0'}}
    end

    def build_sphinx_client_configuration
      {:extra => {:address => sphinx_servers.first[:internal_ip]}}
    end
<%- end -%>
<%- if mongodb? -%>

    def build_mongodb_iptables_configuration
      rules = build_base_iptables_rules

      (servers_with_rails_env + mongodb_servers).each do |server|
        rules << "-A INPUT -s #{server[:internal_ip]} -p tcp -m tcp --dport 27017 -j ACCEPT"
      end

      {:rules => rules}
    end

    def mongodb_replset
      configuration[:application]
    end

    def build_mongodb_configuration
      {
        :replset => mongodb_replset,
        :bind_ip => Facter.ipaddress_eth1
      }
    end

    def build_mongodb_replset_initiate_config_object
      members = mongodb_servers.map do |server|
        id = server[:hostname].match(/mongo(\d+)\./)[1]
        "{_id: #{id}, host: '#{server[:internal_ip]}'}"
      end

    "{_id: '#{mongodb_replset}', members: [#{members.join(', ')}]}"
    end
<%- end -%>

<%- if mmm? -%>
    def mmm_monitor_server
      haproxy_servers.first
    end

    def mmm_monitor_server?
      Facter.fqdn == mmm_monitor_server[:hostname]
    end 

<%- end -%>

     def servers_with_rails_env
       (<%= servers_with_rails_env.join(' + ') %>)
     end
  end

  # override from moonshine_mysql_slave for mmm/multi_server support
  def build_mysql_slave_info(slaves = nil)
    database_servers.map do |database_server|
      {:host => database_server[:ip], :mysql_address => database_server[:internal_ip]}
    end
  end
end
