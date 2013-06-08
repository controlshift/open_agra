require 'active_support/concern'

module HasPaperclipImage
  PAPERCLIP_COLUMNS = [:file_name, :content_type, :file_size, :updated_at]

  extend ActiveSupport::Concern

  included do
    class_attribute :image_field_name
  end

  module ClassMethods

    def has_paperclip_image(options)
      self.image_field_name = options[:field_name].present? ? options[:field_name] : :image
      has_attached_file self.image_field_name, Rails.configuration.paperclip_options.merge(styles: options[:styles], :processors => [:cropper])
      validates_attachment_content_type(self.image_field_name, content_type: /image\/.+/, message: "must be an image file")
      after_validation :sanitize_image_errors_for_simple_form
      attr_accessible self.image_field_name, *paperclip_columns if options[:attr_accessible]
      before_update :reprocess_image, :if => :cropping?
    end

    def paperclip_columns
       PAPERCLIP_COLUMNS.collect{|field| "#{self.image_field_name}_#{field}".intern}
    end
  end

  module InstanceMethods


    def sanitize_image_errors_for_simple_form
      orig_errors = errors.to_hash
      field_name = self.class.image_field_name
      errors.clear
      orig_errors.except(field_name).each do |field, messages|
        messages.each { |message| errors.add(field, message) }
      end
      self.class.paperclip_columns.each do |column|
        errors.add(field_name, errors[column].first) if errors[column].present?
      end
    end

    def reprocess_image
      image = self.send(self.class.image_field_name.intern)
      image.reprocess!
    end

    def cropping?
      false
    end

    def original_to_large_ratio
      image = self.send(self.class.image_field_name.intern)

      if(image.path(:original) && File.exists?(image.path(:original)))
        Paperclip::Geometry.from_file(image.path(:original)).height / Paperclip::Geometry.from_file(image.path(:large)).height
      else
        Paperclip::Geometry.from_file(image.url(:original)).height / Paperclip::Geometry.from_file(image.url(:large)).height
      end
    end
  end
end