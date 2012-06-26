class CreateCategorizedPetitions < ActiveRecord::Migration
  def change
    create_table :categorized_petitions do |t|
      t.references :category
      t.references :petition

      t.timestamps
    end
    
    add_index :categorized_petitions, :category_id
  end
end
