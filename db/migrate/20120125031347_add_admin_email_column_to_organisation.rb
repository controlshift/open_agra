class AddAdminEmailColumnToOrganisation < ActiveRecord::Migration
  def change
    add_column :organisations, 'admin_email', :string
  end
end
