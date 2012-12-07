module Documents
  class Pdf < Queries::Query
    attr_accessor :petition

    def organisation
      @organisation ||= petition.organisation
    end

    def signature_disclaimer
      @signature_disclaimer ||= organisation.signature_disclaimer
    end

    def render(filepath = "")
      if filepath.present?
        generate_pdf.render_file filepath
      else
        generate_pdf.render
      end
    end

    def render_table(pdf, data, table_options = {}, cell_borders, cell_padding)
      table_options.merge!( { :header => true, :row_colors => ["FFFFFF", "EEEEEE"] })

      pdf.table(data, table_options) do
        cells.padding = cell_padding
        cells.borders = cell_borders
        cells.border_width = 1
        cells.border_color = "CCCCCC"

        row(0).font_style = :bold
        row(0).columns(4).size = 8
      end
    end

    def generate_pdf
      binding = self
      Prawn::Document.new(:page_size => "A4", :page_layout => page_layout, :margin => 50) do |pdf|
        pdf.font "Helvetica"
        pdf.font_size 12

        pdf.bounding_box([0, pdf.cursor], :width => 495) do
          pdf.text "To: #{binding.petition.who}"
          pdf.move_down 20
          pdf.text "#{binding.petition.what}"
          binding.top_content_insert(pdf)
        end
        pdf.move_down 20
        pdf.font_size 10
        binding.main_body_content(pdf)
        binding.bottom_content_insert(pdf)
      end
    end

    def top_content_insert(pdf) ; end
    def bottom_content_insert(pdf) ; end
    def main_body_content(pdf) ; end
  end
end