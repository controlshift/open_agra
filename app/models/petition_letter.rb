require 'prawn'

class PetitionLetter
  def self.create_pdf(petition, is_blank = false, filepath = "")
    page_layout = is_blank ? :landscape : :portrait
    pdf = Prawn::Document.new(:page_size => "A4", :page_layout => page_layout, :margin => 50) do
      if page.layout == :landscape
        page_height = 595.28
        page_width = 841.89
        content_height = 495
        content_width = 742
      else
        page_width = 595.28
        page_height = 841.89
        content_width = 495
        content_height = 742
      end
      
      font "Helvetica"
      font_size 12

      bounding_box([0, cursor], :width => 495) do
        text "To: #{petition.who}"
        move_down 20
        text "#{petition.what}"
        
        unless is_blank
          move_down 20
          text "Signed by #{petition.cached_signatures_size} people:"
        end
      end

      move_down 20
      if is_blank
        font_size(7) {
          text "By joining #{petition.organisation.combined_name} you acknowledge that you may receive emails from time to time."
        }
        move_down 2
      end
  
      font_size 10

      data = []
      table_options = { :header => true, :row_colors => ["FFFFFF", "EEEEEE"] }
      cells_borders = [:bottom]
      cells_padding = [5, 15, 5, 15]
  
      if is_blank
        available_space = cursor - 50 + content_height # remaining space + another A4 space
        rows = (available_space / (10 + 20 + 2)).to_i - 2 #font height + padding + border
        
        data = [["Name", "Email", "Postcode", "Phone", "Join #{petition.organisation.combined_name}"]]
        data << ["John Smith", "john@smith.com", "2000", "0412374839", "X"]
        rows.times { data << [" ", " ", " ", " ", " "] }
        table_options[:width] = content_width
        table_options[:position] = :center
        table_options[:cell_style] = { :align => :center }
        if page.layout == :landscape
          table_options[:column_widths] = { 0 => 200, 1 => 250, 2 => 60, 3 => 110 }
        else
          table_options[:column_widths] = { 0 => 120, 1 => 180, 3 => 90 }
        end
        cells_borders = [:top, :bottom, :right, :left]
        cells_padding = [10, 0, 10, 0]
      else
        data << ["Name", "Postcode"]
        petition.signatures.each do |sign|
          data << [sign.full_name, sign.postcode]
        end
      end
  
      if is_blank
        font_size(8) {
          text_box "<strong>Important</strong> - don't forget to enter in the details of your new supporters.  You can do that by going to your manage page on #{petition.organisation.host}", :at => [0, 0], :height => 40, :width => content_width, :inline_format => true
        }
      end

      table(data, table_options) do
        cells.padding = cells_padding
        cells.borders = cells_borders
        cells.border_width = 1
        cells.border_color = "CCCCCC"

        row(0).font_style = :bold
        row(0).columns(4).size = 8
      end

    end
  
    if filepath.present?
      pdf.render_file filepath
    else
      pdf.render
    end
  end
end
