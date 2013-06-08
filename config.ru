# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

if Rails.env.profile?
  use Rack::RubyProf, :path => '/tmp/profile'
end

use Rack::Deflater
run Agra::Application
