require 'facter'

if Facter.hostname =~ /solr/
  God.watch do |w|
    w.name     = 'sunspot-solr'
    w.uid      = 'rails'
    w.interval = 30.seconds
    w.grace    = 15.seconds
  
    w.start    = "bundle exec sunspot-solr run --data-dir=#{RAILS_ROOT}/solr/data --solr-home=#{RAILS_ROOT}/solr"
    w.log      = File.join(RAILS_ROOT, 'log', "#{w.name}.god.log")
  
    w.dir      = RAILS_ROOT
    w.env      = { 'RAILS_ENV' => RAILS_ENV }
  
    w.start_if do |start|
      start.condition(:process_running) do |c|
        c.interval = 5.seconds
        c.running  = false
      end
    end
  
  end
end
