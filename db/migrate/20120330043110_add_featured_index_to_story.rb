class AddFeaturedIndexToStory < ActiveRecord::Migration
  def change
    remove_index :stories, :organisation_id
    add_index :stories, [:organisation_id, :featured]
  end
end
