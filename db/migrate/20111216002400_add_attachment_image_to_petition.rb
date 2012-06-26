class AddAttachmentImageToPetition < ActiveRecord::Migration
  def change
    add_column :petitions, :image_file_name, :string
    add_column :petitions, :image_content_type, :string
    add_column :petitions, :image_file_size, :integer
    add_column :petitions, :image_updated_at, :datetime
  end
end
