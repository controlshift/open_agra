class AddAchievementsColumnToPetition < ActiveRecord::Migration
  def change
    add_column :petitions, :achievements, :text
  end
end
