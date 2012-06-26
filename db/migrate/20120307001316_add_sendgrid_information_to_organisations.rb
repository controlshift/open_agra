class AddSendgridInformationToOrganisations < ActiveRecord::Migration
  def change
    add_column :organisations, :sendgrid_username, :string
    add_column :organisations, :sendgrid_password, :string
  end
end
