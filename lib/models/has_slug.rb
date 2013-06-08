require 'active_support/concern'

module HasSlug
  extend ActiveSupport::Concern

  included do
    before_validation :create_slug!
    validates :slug, uniqueness: true
  end

  module ClassMethods
  end

  module InstanceMethods
    def to_param
      slug
    end
    
    def create_slug!
      return slug unless slug.blank?
      field =  self.respond_to?(:title) ? title : name
      parameterized_name = field.blank? ? 'default-slug' : field.parameterize
      self.slug = parameterized_name
      counter = 1
      while (self.class.find_by_slug(slug))
        self.slug = "#{parameterized_name}-#{counter}"
        counter += 1
      end
      slug
    end
    
  end
end
