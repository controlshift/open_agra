module Queries
  class Query
    include ActiveModel::Validations
    extend ActiveModel::Naming
    include ActiveModel::Conversion

    def initialize(attrs = {})
      attrs.each do |key,value|
        if self.respond_to?("#{key}=")
          self.send("#{key}=", value)
        end
      end
    end


    def persisted?
      false
    end

    def self.reflect_on_association(association)
      nil
    end
  end
end
