class AddGoogleAnalyticsIdToOrganisation < ActiveRecord::Migration
  def change
    add_column :organisations, :google_analytics_tracking_id, :string
  end
end
