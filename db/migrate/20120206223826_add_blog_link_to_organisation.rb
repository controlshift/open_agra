class AddBlogLinkToOrganisation < ActiveRecord::Migration
  def change
    add_column :organisations, :blog_link, :string
  end
end
