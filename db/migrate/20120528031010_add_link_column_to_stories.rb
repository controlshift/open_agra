class AddLinkColumnToStories < ActiveRecord::Migration
  def change
    add_column :stories, :link, :string
  end
end
