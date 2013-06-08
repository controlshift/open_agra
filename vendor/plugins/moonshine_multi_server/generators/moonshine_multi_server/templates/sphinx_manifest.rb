require "#{File.dirname(__FILE__)}/base_manifest.rb"

class SphinxManifest < BaseManifest

  configure :sphinx => build_sphinx_server_configuration
  configure :iptables => build_sphinx_iptables_configuration
  recipe :standalone_sphinx_stack

end
