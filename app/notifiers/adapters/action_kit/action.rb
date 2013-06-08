module Adapters
  module ActionKit
    class Action
      include GoingPostal

      attr_accessor :user_details
      attr_accessor :organisation
      attr_accessor :petition

      def initialize(attrs = {})
        attrs.each do |key,value|
          if self.respond_to?("#{key}=")
            self.send("#{key}=", value)
          end
        end
      end

      def to_hash(page = nil)
        hash = default_fields.merge!(custom_fields)
        page = page ? page : petition.external_id
        hash.merge!(page: page)
      end

      def custom_fields
        begin
          extension_module = "Adapters::ActionKit::ActionFields::#{organisation.slug.capitalize}".constantize
          extension_module.custom_fields(user_details)
        rescue NameError
          {}
        end
      end

      def default_fields
        data = {
            first_name: user_details.first_name,
            last_name: user_details.last_name,
            email: user_details.email,
            zip: formatted_postcode,
            created_at: user_details.created_at,
            home_phone: user_details.phone_number,
            list: '1'
        }
        data[:source] = (user_details.respond_to?(:source) && user_details.source.present?) ? "controlshift_#{user_details.source}" : 'controlshift'
        data[:referring_akid] = user_details.akid if user_details.respond_to?(:akid) && user_details.akid.present?
        data[:country] = country if country.present?
        data[:action_categories] = category_slugs if category_slugs.present?
        data
      end

      def category_slugs
        petition.categories.map {|c| c.slug }
      end

      def country
        if petition.location.present? && petition.location.country.present?
          petition.location.country
        elsif organisation.action_kit_country.present?
          organisation.action_kit_country
        else
          nil
        end
      end

      def formatted_postcode
        if country
          fp = format_postcode(user_details.postcode, country)
          fp.present? ? fp : user_details.postcode
        else
          match = user_details.postcode.match /(\d\d\d\d\d)\s?-?\s?(\d\d\d\d)/
          if match
            "#{match[1]}-#{match[2]}"
          else
            user_details.postcode
          end
        end
      end
    end
  end
end