namespace :god do
  namespace :sidekiq do
    desc "start sidekiq workers"
    task :start, :roles => :sidekiq do
      sudo "god start #{fetch(:application)}-sidekiq || true"
    end
    desc "stop sidekiq workers"
    task :stop, :roles => :sidekiq do
      sudo "god stop #{fetch(:application)}-sidekiq || true"
    end
    desc "restart sidekiq workers"
    task :restart, :roles => :sidekiq do
      sudo "god restart #{fetch(:application)}-sidekiq || true"
    end

    desc "show status of sidekiq workers"
    task :status, :roles => :sidekiq do
      sudo "god status #{fetch(:application)}-sidekiq || true"
    end
  end
end
