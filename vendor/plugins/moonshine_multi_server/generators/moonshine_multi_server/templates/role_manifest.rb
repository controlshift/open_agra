require "#{File.dirname(__FILE__)}/base_manifest.rb"

class <%= role.classify %>Manifest < BaseManifest
  recipe :default_system_config
  recipe :non_rails_recipes
end
