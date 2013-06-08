require 'active_model'
require 'shorten_attributes'

module ActiveModel::Validations::HelperMethods
  # Silently shortens attributes to 254 characters.
  def shorten_attributes(options = nil)
    before_validation do |record|
      attributes = StripAttributes.narrow(record.attributes, options)
      attributes.each do |attr, value|
        if value.respond_to?(:slice)
          record[attr] = (value.blank?) ? '' : value.slice(0, 253)
        end
      end
    end
  end
end