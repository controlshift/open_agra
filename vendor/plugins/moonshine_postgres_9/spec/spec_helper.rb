require 'rubygems'
ENV['RAILS_ENV'] = 'test'
ENV['RAILS_ROOT'] ||= File.dirname(__FILE__) + '/../../../..'

require File.join(File.dirname(__FILE__), '..', '..', 'moonshine', 'lib', 'moonshine.rb')
require File.join(File.dirname(__FILE__), '..', 'lib', 'postgres_9.rb')

require 'shadow_puppet/test'

class Postgres9Manifest < Moonshine::Manifest::Rails
  path = Pathname.new(__FILE__).dirname.join('..', 'moonshine', 'init.rb')
  Kernel.eval(File.read(path), binding, path)
end
