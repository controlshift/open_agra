class AddAttachmentImageToEffort < ActiveRecord::Migration
  def change
    add_column :efforts, :image_file_name, :string
    add_column :efforts, :image_content_type, :string
    add_column :efforts, :image_file_size, :integer
    add_column :efforts, :image_updated_at, :datetime
  end
end
