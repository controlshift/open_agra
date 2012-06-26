module Jobs
  class GeneratePetitionLetterJob
    def initialize(petition, filename)
      @petition = petition
      @filename = filename
    end

    def perform
      data = PetitionLetter.create_pdf(@petition, false)

      file = HttpUploadFile.new(@filename, "application/pdf")
      file.write_data(data)
      
      @petition.update_attribute(:petition_letter, file)

      CampaignerMailer.notify_petition_letter_ready_for_download(@petition).deliver
    end
  end
end