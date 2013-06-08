namespace :god do
  namespace :dj do
    desc "start dj workers"
    task :start, :roles => :dj do
      sudo "god start #{fetch(:application)}-dj || true"
    end
    desc "stop dj workers"
    task :stop, :roles => :dj do
      sudo "god stop #{fetch(:application)}-dj || true"
    end
    desc "restart dj workers"
    task :restart, :roles => :dj do
      sudo "god restart #{fetch(:application)}-dj || true"
    end

    desc "show status of dj workers"
    task :status, :roles => :dj do
      sudo "god status #{fetch(:application)}-dj || true"
    end
  end
end
