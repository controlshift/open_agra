class AddWelcomeEmailToEfforts < ActiveRecord::Migration
  def change
    add_column :efforts, :thanks_for_creating_email, :text
  end
end
