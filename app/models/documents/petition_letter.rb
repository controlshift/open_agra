module Documents
  class PetitionLetter < Pdf
    include ActionView::Helpers::NumberHelper

    def page_layout
      :portrait
    end

    def content_height
      742
    end

    def content_width
      495
    end

    def top_content_insert(pdf)
       pdf.move_down 20
       pdf.text "Signed by #{number_with_delimiter(petition.cached_signatures_size)} people:"
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

    def additional_field_columns(signature)
      additional_field_keys.map{|key| signature.respond_to?(key.intern) ? render_additional_field(signature, key) : "" }
    end

    def render_additional_field(signature, key)
      if signature.respond_to?("#{key}?".intern)
        signature.send("#{key}?".intern) ? "x" : ""
      else
        signature.send(key.intern)
      end
    end

    def main_body_content(pdf)
      cells_borders = [:bottom]
      cells_padding = [5, 15, 5, 15]

      render_table(pdf, table_data, {column_widths: { 0 => 120, 1 => 180, 3 => 90 }}, cells_borders, cells_padding)
    end

    def table_data
      data = []
      data << ["Name", "Postcode"] + additional_field_keys.map(&:humanize)
      petition.signatures.find_in_batches do |batch|
        batch.each do |sign|
          data << [sign.full_name, sign.postcode.upcase] + additional_field_columns(sign)
        end
      end
      data
    end
  end
end