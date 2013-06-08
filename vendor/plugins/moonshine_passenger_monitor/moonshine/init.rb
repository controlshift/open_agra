require 'pathname'
$LOAD_PATH.unshift Pathname.new(__FILE__).dirname.join('..', 'lib').expand_path
require 'moonshine/passenger_monitor'

include Moonshine::PassengerMonitor
