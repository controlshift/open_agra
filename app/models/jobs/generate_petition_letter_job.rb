require 'zip/zip'

module Jobs
  class GeneratePetitionLetterJob
    def initialize(petition, filename, user)
      @petition = petition
      @filename = filename
      @user = user
    end

    def perform
      if @petition.cached_signatures_size < 50000
        generate_single_pdf
      else
        generate_zipped_pdfs
      end
      GC.start
      end

    def generate_single_pdf
      data = Documents::PetitionLetter.new(petition: @petition ).render

      file = HttpUploadFile.new(@filename, "application/pdf")
      file.write_data(data)

      @petition.update_attribute(:petition_letter, file)

      CampaignerMailer.notify_petition_letter_ready_for_download(@petition, @user).deliver
    end

    def generate_zipped_pdfs
      pdf_files = []
      @petition.signatures.select([:id, :first_name, :last_name, :postcode, :additional_fields, :cached_organisation_slug]).find_in_batches(batch_size: 10000) do | batch |
        file = Tempfile.new('petition_letter')
        Documents::MultiPetitionLetter.new(petition: @petition, batch: batch ).render(file.path)
        pdf_files << file
        GC.start
      end

      zip =  HttpUploadFile.new("#{@petition.slug}.zip", "application/zip")
      Zip::ZipOutputStream.open(zip.path) do |z|
        counter = 0
        pdf_files.each do |file|
          counter = counter + 1
          z.put_next_entry("signatures_#{counter}.pdf")
          z.print IO.read(file.path)
        end
      end

      @petition.update_attribute(:petition_letter, zip)

      CampaignerMailer.notify_petition_letter_ready_for_download(@petition, @user).deliver
      GC.start
    end
  end
end