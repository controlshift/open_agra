require "#{File.dirname(__FILE__)}/base_manifest.rb"

class DjManifest < BaseManifest

  recipe :rails_recipes
  recipe :application_packages

  recipe :dj
  recipe :god
  
  recipe :cron_jobs
  
  def cron_jobs
  end
    
end
