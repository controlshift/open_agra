class AddDefaultForCampaignerContactable < ActiveRecord::Migration
  def change
    change_column :petitions, :campaigner_contactable, :boolean, default: true
  end
end
