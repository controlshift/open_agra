class AddFeaturedColumnForEffort < ActiveRecord::Migration
  def change
    add_column :efforts, 'featured', :boolean, default: false
  end
end
