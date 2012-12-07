class FixOrganisationHostIndex < ActiveRecord::Migration
  def up
    remove_index(:organisations, :host)
    execute "CREATE UNIQUE INDEX lower_case_organisations_host ON organisations (lower(host));"
  end

  def down
    execute "drop index if exists lower_case_organisations_host";
    add_index(:organisations, :host, unique: true)
  end
end
