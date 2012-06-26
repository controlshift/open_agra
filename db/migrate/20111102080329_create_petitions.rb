class CreatePetitions < ActiveRecord::Migration
  def change
    create_table :petitions do |t|
      t.string :title
      t.string :who_petitioning
      t.text :why_important
      t.text :what_want

      t.timestamps
    end
  end
end
