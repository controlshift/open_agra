class AddTrainingTextForEfforts < ActiveRecord::Migration
  def change
     add_column :efforts, :training_text, :text
  end
end
