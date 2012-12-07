class AddDefaultAttachmentImageForPetitionWithinEffort < ActiveRecord::Migration
  def change
    add_column :efforts, :image_default_file_name,    :string
    add_column :efforts, :image_default_content_type, :string
    add_column :efforts, :image_default_file_size,    :integer
    add_column :efforts, :image_default_updated_at,   :datetime
  end
end
