module BooleanFields
  extend ActiveSupport::Concern

  module ClassMethods
    def boolean_fields(*fields)
      fields.each do |boolean_field|
        define_method "#{boolean_field}?" do
          self.send(boolean_field) == '1' ||  self.send(boolean_field) == 'true' || self.send(boolean_field) == true
        end
      end
    end
  end
end