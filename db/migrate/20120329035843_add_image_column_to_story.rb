class AddImageColumnToStory < ActiveRecord::Migration
  def self.up
    change_table :stories do |t|
      t.has_attached_file :image
    end
  end

  def self.down
    drop_attached_file :stories, :image
  end
end
