class AddOptOutSiteEmailToUser < ActiveRecord::Migration
  def change
    add_column :users, :opt_out_site_email, :boolean
  end
end
