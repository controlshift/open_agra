module Adapters
  module ActionKit
    class Page
      attr_accessor :organisation
      attr_accessor :petition

      def initialize(attrs = {})
        attrs.each do |key,value|
          if self.respond_to?("#{key}=")
            self.send("#{key}=", value)
          end
        end
      end

      def to_hash
        default_fields.merge(tags).merge(custom_fields)
      end

      def default_fields
        {
          name: "controlshift-#{petition.slug}",
          title: "ControlShift: #{petition.title}"
        }
      end

      def custom_fields
        begin
          extension_module = "Adapters::ActionKit::PageFields::#{organisation.slug.capitalize}".constantize
          extension_module.custom_fields(petition)
        rescue NameError
          {}
        end
      end

      def tags
        tags = petition.categories.collect do |category|
          tag_resource_uri_for(category.external_id)
        end

        tags = tags.push( tag_resource_uri_for(organisation.action_kit_tag_id))

        {tags: tags}
      end

      def tag_resource_uri_for(id)
        "/rest/v1/tag/#{id}/"
      end
    end
  end
end