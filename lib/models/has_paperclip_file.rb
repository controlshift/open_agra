require 'active_support/concern'

module HasPaperclipFile
  extend ActiveSupport::Concern

  included do

  end

  module ClassMethods
    def has_paperclip_file(attr_name, options)
      paperclip_options = options[:paperclip_options] || {}
      has_attached_file attr_name, Rails.configuration.paperclip_file_options.merge(paperclip_options)
      eval("before_#{attr_name}_post_process :should_preprocess_file")
      attr_accessible attr_name if options[:attr_accessible]
    end
  end

  module InstanceMethods
    def should_preprocess_file
      false
    end
  end
end