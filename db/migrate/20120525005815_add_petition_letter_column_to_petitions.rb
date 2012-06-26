class AddPetitionLetterColumnToPetitions < ActiveRecord::Migration
  def change
    change_table :petitions do |t|
      t.has_attached_file :petition_letter
    end
  end
end
