class AddParentUrlToOrganisation < ActiveRecord::Migration
  def change
    add_column :organisations, :parent_url, :string
    add_column :organisations, :facebook_url, :string
    add_column :organisations, :twitter_url, :string
  end
end
