class AddShowPetitionCategoryOnCreationToOrganisation < ActiveRecord::Migration
  def change
    add_column :organisations, :show_petition_category_on_creation, :boolean
  end
end
