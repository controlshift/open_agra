require 'csv'

module Queries
  module Exports
    class Export < Query
      attr_accessor :organisation

      def name
        klass.to_s.pluralize.downcase
      end

      def sql
        raise "implement me!"
      end

      def organisation_id
        ActiveRecord::Base.sanitize(organisation.id)
      end

      def record_set
        @record_set ||= ActiveRecord::Base.connection.execute(sql)
      end

      def first_row
        @first_row ||= ActiveRecord::Base.connection.execute(sql + " LIMIT 1").to_a.first
      end

      def additional_field_keys
        if defined?(@additional_field_configs)
          @additional_field_configs
        else
          sig = Signature.new(default_organisation_slug: organisation.slug)
          @additional_field_configs = if sig.respond_to?(:additional_field_configs)
            sig.additional_field_configs.keys.map(&:to_s)
          else
            []
          end
        end
      end

      def find_in_batches(options = {})
        batch_size = options[:batch_size] || 10000
        primary_key_offset = options[:primary_key_offset] || 0

        records = records_for_batch(batch_size, primary_key_offset)

        while records.any?
          primary_key_offset = records.last['id']

          yield records

          break if records.size < batch_size

          if primary_key_offset
            records = records_for_batch(batch_size, primary_key_offset)
          else
            raise "Primary key not included in the custom select clause"
          end
        end
      end

      def records_for_batch(batch_size, primary_key_offset)
        ActiveRecord::Base.connection.execute(sql_for_batch(batch_size, primary_key_offset)).to_a
      end

      def sql_for_batch(batch_size, primary_key_offset)
        "#{sql} AND id > #{ActiveRecord::Base.sanitize(primary_key_offset)} LIMIT #{ActiveRecord::Base.sanitize(batch_size)}"
      end


      def as_csv_stream
        Enumerator.new do |response_blob|
          if first_row.present?

            # insert the first header row
            response_blob << CSV.generate do |csv|
              csv << header_row
            end

            find_in_batches do |batch|
              response_blob << CSV.generate do |csv|
                batch.each do |row|
                  csv << generate_row(row)
                end
              end
            end
          end
        end
      end

      def header_row
        columns = first_row.keys - ["additional_fields", "cached_organisation_slug"]

        additional_field_keys.each do |field|
          columns << field
        end

        columns
      end

      def generate_row(row)
        columns = row.keys - ["additional_fields", "cached_organisation_slug"]

        csv_row = columns.collect do |c|
          format_cell(row[c])
        end

        if additional_field_keys.any?
          additional_fields = row["additional_fields"].from_hstore if row["additional_fields"]
          additional_field_keys.each do |field|
            csv_row << (additional_fields.nil? ? nil : additional_fields[field])
          end
        end
        csv_row
      end

      def format_cell(value)
        value.is_a?(DateTime) ? value.strftime("%Y-%m-%d %H:%M:%S") : value
      end

      def filter_column_names(columns_to_exclude = [])
        (klass.column_names - columns_to_exclude).join(',')
      end
    end
  end
end