class AddTrainingSidebarTextForEffort < ActiveRecord::Migration
  def change
     add_column :efforts, :training_sidebar_text, :text
  end
end
