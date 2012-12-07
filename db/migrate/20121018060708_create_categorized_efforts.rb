class CreateCategorizedEfforts < ActiveRecord::Migration
  def change
    create_table :categorized_efforts do |t|
      t.references :category
      t.references :effort

      t.timestamps
    end
  end
end
