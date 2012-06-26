class AddAdminNotesToPetition < ActiveRecord::Migration
  def change
    add_column :petitions, :admin_notes, :text
  end
end
