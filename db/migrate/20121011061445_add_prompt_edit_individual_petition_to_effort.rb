class AddPromptEditIndividualPetitionToEffort < ActiveRecord::Migration
  def change
    add_column :efforts, :prompt_edit_individual_petition, :boolean, default: false
  end
end
