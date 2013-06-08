$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/../lib/"
require 'moonshine/multi_server'

# Instead of including the Moonshine::MultiServer module here, 
# we need to include it in the manifests so that we can 
# redefine some methods from Moonshine::Manifest::Rails
