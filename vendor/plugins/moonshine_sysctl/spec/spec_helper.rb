require 'rubygems'
ENV['RAILS_ENV'] = 'test'
ENV['RAILS_ROOT'] ||= File.dirname(__FILE__) + '/../../../..'

require File.join(ENV['RAILS_ROOT'], 'vendor', 'plugins', 'moonshine', 'lib', 'moonshine.rb')
require File.join(File.dirname(__FILE__), '..', 'lib', 'sysctl.rb')

require 'shadow_puppet/test'