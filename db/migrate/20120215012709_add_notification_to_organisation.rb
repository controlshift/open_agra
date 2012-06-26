class AddNotificationToOrganisation < ActiveRecord::Migration
  def change
    add_column :organisations, 'notification_url', :string
  end
end
