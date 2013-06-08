namespace :moonshine do

  task :multi_server_apply do
    parallel do |session|
      session.when "in?(:db)", "#{sudo} RAILS_ROOT=#{latest_release} DEPLOY_STAGE=#{fetch(:stage, "production")} RAILS_ENV=#{fetch(:rails_env, "production")} shadow_puppet #{'--noop' if fetch(:noop)} #{latest_release}/app/manifests/database_manifest.rb"
      session.when "in?(:redis)", "#{sudo} RAILS_ROOT=#{latest_release} DEPLOY_STAGE=#{fetch(:stage, "production")} RAILS_ENV=#{fetch(:rails_env, "production")} shadow_puppet #{'--noop' if fetch(:noop)} #{latest_release}/app/manifests/redis_manifest.rb"
      session.when "in?(:memcached)", "#{sudo} RAILS_ROOT=#{latest_release} DEPLOY_STAGE=#{fetch(:stage, "production")} RAILS_ENV=#{fetch(:rails_env, "production")} shadow_puppet #{'--noop' if fetch(:noop)} #{latest_release}/app/manifests/memcached_manifest.rb"
      session.when "in?(:mongodb)", "#{sudo} RAILS_ROOT=#{latest_release} DEPLOY_STAGE=#{fetch(:stage, "production")} RAILS_ENV=#{fetch(:rails_env, "production")} shadow_puppet #{'--noop' if fetch(:noop)} #{latest_release}/app/manifests/mongodb_manifest.rb"
      end

    parallel do |session|
      session.when "in?(:app)", "#{sudo} RAILS_ROOT=#{latest_release} DEPLOY_STAGE=#{fetch(:stage, "production")} RAILS_ENV=#{fetch(:rails_env, "production")} shadow_puppet #{'--noop' if fetch(:noop)} #{latest_release}/app/manifests/application_manifest.rb"
      session.when "in?(:worker)", "#{sudo} RAILS_ROOT=#{latest_release} DEPLOY_STAGE=#{fetch(:stage, "production")} RAILS_ENV=#{fetch(:rails_env, "production")} shadow_puppet #{'--noop' if fetch(:noop)} #{latest_release}/app/manifests/worker_manifest.rb"
      session.when "in?(:sphinx)", "#{sudo} RAILS_ROOT=#{latest_release} DEPLOY_STAGE=#{fetch(:stage, "production")} RAILS_ENV=#{fetch(:rails_env, "production")} shadow_puppet #{'--noop' if fetch(:noop)} #{latest_release}/app/manifests/sphinx_manifest.rb"
      session.when "in?(:sunspot)", "#{sudo} RAILS_ROOT=#{latest_release} DEPLOY_STAGE=#{fetch(:stage, "production")} RAILS_ENV=#{fetch(:rails_env, "production")} shadow_puppet #{'--noop' if fetch(:noop)} #{latest_release}/app/manifests/sunspot_manifest.rb"
      end

    parallel do |session|
      session.when "in?(:web)", "#{sudo} RAILS_ROOT=#{latest_release} DEPLOY_STAGE=#{fetch(:stage, 'production')} RAILS_ENV=#{fetch(:rails_env, 'production')} shadow_puppet #{'--noop' if fetch(:noop)} #{latest_release}/app/manifests/haproxy_manifest.rb"
      end

  end

  task :apply do
    multi_server_apply
  end


end
