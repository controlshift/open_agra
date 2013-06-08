class AddKmeansSupport < ActiveRecord::Migration
  def up
    if execute("SELECT * FROM pg_proc WHERE proname='kmeans'").count == 0
      execute "CREATE EXTENSION IF NOT EXISTS kmeans"
    end
  end

  def down
    execute "DROP EXTENSION IF EXISTS kmeans"
  end
end
