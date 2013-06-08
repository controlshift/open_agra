class AddExternalLinksToPetitions < ActiveRecord::Migration
  def change
    add_column :petitions, :external_facebook_page, :string
    add_column :petitions, :external_site, :string
  end
end
