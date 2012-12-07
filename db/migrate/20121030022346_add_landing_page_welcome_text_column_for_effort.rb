class AddLandingPageWelcomeTextColumnForEffort < ActiveRecord::Migration
  def change
    add_column :efforts, :landing_page_welcome_text, :text
  end
end
