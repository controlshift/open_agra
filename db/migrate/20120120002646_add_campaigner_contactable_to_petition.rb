class AddCampaignerContactableToPetition < ActiveRecord::Migration
  def change
    add_column :petitions, :campaigner_contactable, :boolean
  end
end
