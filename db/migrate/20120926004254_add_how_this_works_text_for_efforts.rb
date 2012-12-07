class AddHowThisWorksTextForEfforts < ActiveRecord::Migration
  def change
     add_column :efforts, :how_this_works_text, :text
  end
end
