class RenameTwitterUrlOfOrganisationTable < ActiveRecord::Migration
  def change
    rename_column :organisations, :twitter_url, :twitter_account_name
  end
end
