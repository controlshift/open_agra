class AddFieldsToOrganisation < ActiveRecord::Migration
  def change
    add_column :organisations, :slug, :string
    add_column :organisations, :host, :string
    add_index  :organisations, :host

  end
end
