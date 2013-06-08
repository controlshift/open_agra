set :postgresql_version do
  moonshine_yml[:postgresql][:version] || '9.0'
end

namespace :postgresql do
  task :version do
    puts postgresql_version
  end

  namespace :standby do
    task :bringup, :roles => :db, :only => {:standby => true} do
      sudo "touch /var/lib/postgresql/#{postgresql_version}/main/BRINGUP", :as => 'postgres'
    end
  end

  namespace :replication do
    task :public_keys, :roles => :db do
      sudo "cat /var/lib/postgresql/.ssh/id_rsa.pub", :as => 'postgres'
    end

    namespace :status do
      task :default, :roles => :db do
        tail
        current_xlog_location
        last_xlog_receive_location
        last_xlog_replay_location
      end

      task :tail, :roles => :db do
        sudo %Q{tail /var/log/postgresql/postgresql-#{postgresql_version}-main.log}
      end

      task :current_xlog_location, :roles => :db, :only => {:primary => true} do
        sudo %Q{psql -c 'SELECT pg_current_xlog_location()'}, :as => 'postgres'
      end

      task :last_xlog_receive_location, :roles => :db, :only => {:standby => true} do
        sudo %Q{psql -c 'SELECT pg_last_xlog_receive_location()'}, :as => 'postgres'
      end

      task :last_xlog_replay_location, :roles => :db, :only => {:standby => true} do
        sudo %Q{psql -c 'SELECT pg_last_xlog_replay_location()'}, :as => 'postgres'
      end

    end

    namespace :setup do
      task :wal_archiving_status, :roles => :db, :only => {:primary => true} do
        sudo %Q{psql -c 'show archive_mode'}, :as => 'postgres'
        sudo %Q{ps aux | grep "wal writer" | grep -v grep}
      end

      task :default do
        take_snapshot_from_primary
        copy_snapshot_from_primary_to_standby
        apply_snapshot_to_standby
      end
      task :take_snapshot_from_primary, :roles => :db, :only => {:primary => true} do
        sudo %Q{psql -c "SELECT pg_start_backup('base_backup')"}, :as => 'postgres'
        sudo %Q{rm -f /tmp/main.tar.gz}
        sudo %Q{tar -C /var/lib/postgresql/#{postgresql_version}/main --exclude postmaster.pid -czvf /tmp/main.tar.gz ./}, :as => 'postgres'
        # FIXME this command usually hangs forever with output like:
        #  ** [out :: server] NOTICE:  pg_stop_backup cleanup done, waiting for required WAL segments to be archived
        #  ** [out :: server] WARNING:  pg_stop_backup still waiting for all required WAL segments to be archived (60 seconds elapsed)
        #  ** [out :: server] HINT:  Check that your archive_command is executing properly.  pg_stop_backup can be cancelled safely, but the database backup will not be usable without all the WAL segments.
        sudo %Q{psql -c "SELECT pg_stop_backup()"}, :as => 'postgres'
      end

      task :copy_snapshot_from_primary_to_standby do
        run_locally "mkdir -p tmp"
        get "/tmp/main.tar.gz", "tmp/main.tar.gz", :roles => :db, :only => {:primary => true}
        upload "tmp/main.tar.gz", "/tmp/main.tar.gz", :roles => :db, :only => {:standby => true}
      end

      task :apply_snapshot_to_standby, :roles => :db, :only => {:standby => true} do
        sudo "service postgresql stop"
        sudo "rm -rf /var/lib/postgresql/#{postgresql_version}/main.old", :as => 'postgres'
        sudo "mv /var/lib/postgresql/#{postgresql_version}/main /var/lib/postgresql/#{postgresql_version}/main.old", :as => 'postgres'
        sudo "mkdir -p /var/lib/postgresql/#{postgresql_version}/main", :as => 'postgres'
        sudo "chmod 700 /var/lib/postgresql/#{postgresql_version}/main", :as => 'postgres'
        sudo "tar -C /var/lib/postgresql/#{postgresql_version}/main -xzf /tmp/main.tar.gz", :as => 'postgres'
        sudo "ln -s /var/lib/postgresql/recovery.conf /var/lib/postgresql/#{postgresql_version}/main/recovery.conf", :as => 'postgres'
        sudo "id", :as => 'postgres'
        sudo "service postgresql start"
      end

      task :cleanup, :roles => :db do
        run_locally "rm -f tmp/main.tar.gz"
        sudo "rm -f /tmp/main.tar.gz"
      end
    end
  end
end
