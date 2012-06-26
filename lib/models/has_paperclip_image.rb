PAPERCLIP_COLUMNS = [:image_file_name, :image_content_type, :image_file_size, :image_updated_at]

require 'active_support/concern'

module HasPaperclipImage
  extend ActiveSupport::Concern

  included do

  end

  module ClassMethods
    def has_paperclip_image(options)
      has_attached_file :image, Rails.configuration.paperclip_options.merge(styles: options[:styles])
      validates_attachment_content_type(:image, content_type: /image\/.+/, message: "must be an image file")
      after_validation :sanitize_image_errors_for_simple_form
      attr_accessible :image, *PAPERCLIP_COLUMNS if options[:attr_accessible]
    end
  end

  module InstanceMethods
    def sanitize_image_errors_for_simple_form
      orig_errors = errors.to_hash
      errors.clear
      orig_errors.except(:image).each do |field, messages|
        messages.each { |message| errors.add(field, message) }
      end
      PAPERCLIP_COLUMNS.each do |column|
        errors.add(:image, errors[column].first) if errors[column].present?
      end
    end
    
  end
end