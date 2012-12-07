module Documents
  class PetitionForm < Pdf
    def page_layout
      :landscape
    end

    def content_height
      495
    end

    def content_width
      742
    end

    def top_content_insert(pdf)
      pdf.font_size(7) {
        if signature_disclaimer.blank?
          pdf.text "By joining #{petition.organisation.combined_name} you acknowledge that you may receive emails from time to time."
        else
          pdf.text signature_disclaimer
        end
      }
      pdf.move_down 2
    end

    def main_body_content(pdf)
      available_space = pdf.cursor - 50 + content_height # remaining space + another A4 space
      rows = (available_space / (10 + 20 + 2)).to_i - 2 #font height + padding + border
      if organisation.always_join_parent_org_when_sign_up?
        data = [["Name", "Email", "Postcode", "Phone"]]
        data << ["John Smith", "john@smith.com", "2000", "0412374839"]
        rows.times { data << [" ", " ", " ", " "] }
      else
        data = [["Name", "Email", "Postcode", "Phone", "Join #{organisation.combined_name}"]]
        data << ["John Smith", "john@smith.com", "2000", "0412374839", "X"]
        rows.times { data << [" ", " ", " ", " ", " "] }
      end


      table_options = {}
      table_options[:position] = :center
      table_options[:cell_style] = { :align => :center }

      if organisation.always_join_parent_org_when_sign_up?
        table_options[:column_widths] = { 0 => 220, 1 => 260, 2 => 130, 3 => 130 }
      else
        table_options[:width] = content_width
        table_options[:column_widths] = { 0 => 200, 1 => 250, 2 => 60, 3 => 110}
      end

      cells_borders = [:top, :bottom, :right, :left]
      cells_padding = [10, 0, 10, 0]

      render_table(pdf, data, table_options, cells_borders, cells_padding)
    end

    def bottom_content_insert(pdf)
      pdf.font_size(8) {
        pdf.text_box "<strong>Important</strong> - don't forget to enter in the details of your new supporters.  You can do that by going to your manage page on #{petition.organisation.host}", :at => [0, 0], :height => 40, :width => content_width, :inline_format => true
      }
    end
  end
end