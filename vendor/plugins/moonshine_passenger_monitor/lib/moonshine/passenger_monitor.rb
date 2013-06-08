module Moonshine
  module PassengerMonitor
    def monitor_template_dir
      Pathname.new(__FILE__).dirname.join('passenger_monitor', 'templates')
    end
    
    def passenger_monitor(options = {})
      options[:memory] ||= 500
      options[:pattern] ||= if rails_root.join('config.ru').exist?
                              "Rack: /srv/#{configuration[:application]}/current"
                            else
                              "Rails: /srv/#{configuration[:application]}/current"
                            end

      file '/usr/local/bin/passenger-memory-monitor',
            :ensure => :present,
            :content => template(monitor_template_dir.join('passenger-memory-monitor'), binding),
            :mode => '755'
      
      if options[:cron] != false
        options[:cron] ||= {}
        cron 'passenger_memory_monitor',
          :command => "/usr/local/bin/passenger-memory-monitor #{options[:memory]} >> /var/log/passenger-memory-monitor.log",
          :minute => options[:cron][:minute] || '*/1',
          :hour => options[:cron][:hour] || '*',
          :monthday => options[:cron][:monthday] || '*',
          :month => options[:cron][:month] || '*',
          :weekday => options[:cron][:weekday] || '*',
          :user => 'root'
      else
        cron 'passenger_memory_monitor', :command => 'true', :ensure => :absent
      end
      
    end
  end
end
