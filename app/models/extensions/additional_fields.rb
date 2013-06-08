module Extensions
  module AdditionalFields
    extend ActiveSupport::Concern

    included do
      include BooleanFields
      serialize :additional_fields, ActiveRecord::Coders::Hstore
      after_initialize :setup_additional_fields
      
      attr_accessible :default_organisation_slug
      attr_accessor   :default_organisation_slug
      class_attribute :_additional_field_extension_cache
      self._additional_field_extension_cache = {}
      self._additional_field_extension_cache.default = true
      validates_with AdditionalFieldValidator
    end

    module InstanceMethods
      def setup_additional_fields
        singleton = class << self; self; end

        # setup storage for additional fields
        singleton.class_eval do
          class_attribute :_additional_field_configs
          self._additional_field_configs = {}
        end

        if (self.organisation_slug.present? &&
            self.has_attribute?(:additional_fields))
          self.cached_organisation_slug = organisation_slug
          self.additional_fields = {} if self.additional_fields.nil?
          extension_module = "Extensions::#{self.class.name}::#{self.organisation_slug.capitalize}"

          # performance optimization to avoid repeated rescue calls.
          if _additional_field_extension_cache[extension_module]
            begin
              singleton.class_eval("include #{extension_module}")
            rescue NameError
              # if we can not load this extension, never try to load it again.
              _additional_field_extension_cache[extension_module] = false
            end
          end
        end
      end

      def sanitize_additional_fields
        self.additional_fields &&= self.additional_fields.map { |key,value| {key.to_s => value} }.inject(:merge)
      end

      def mass_assignment_authorizer(role)
        _active_authorizer[:default]
      end

      def additional_field_configs
        self._additional_field_configs
      end

      def accessible_attributes
        attrs = {}
        accessible_attribute_names.each do |a|
          attrs[a.intern] = self.send(a.intern)
        end
        attrs
      end

      def accessible_attribute_names
        self._accessible_attributes[:default].to_a
      end

      def organisation_slug
        # this attributes check should only fail on Model.exists?() calls, which only load the id attribute.
        # These attempts to load custom organisation behaviors can be safely ignored by returning nil.
        if has_attribute?(:cached_organisation_slug) && cached_organisation_slug.present?
          cached_organisation_slug
        elsif default_organisation_slug.present?
          default_organisation_slug
        else
          nil
        end
      end
    end

    module ClassMethods
      def additional_field(field, options = {})
        self._additional_field_configs[field] =  options
        attr_accessible field
        postgres_hstore_accessor :additional_fields, field
        boolean_fields field if options[:as] == :boolean
      end

      def postgres_hstore_accessor(store_attribute, *keys)
        Array(keys).flatten.each do |key|
          define_method("#{key}=") do |value|
            send(store_attribute)[key.to_s] = value
            send("#{store_attribute}_will_change!")
          end

          define_method(key) do
            send(store_attribute)[key.to_s]
          end
        end
      end
    end
  end
end