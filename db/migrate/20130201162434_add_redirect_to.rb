class AddRedirectTo < ActiveRecord::Migration
  def change
    add_column :petitions, :redirect_to, :text
  end
end
