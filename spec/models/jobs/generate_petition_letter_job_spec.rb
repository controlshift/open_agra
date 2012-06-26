require 'spec_helper'

describe Jobs::GeneratePetitionLetterJob do
  before(:each) do
    @campaigner = Factory(:user)
    @petition = Factory(:petition, user: @campaigner)
    @filename = "test.pdf"
    @job = Jobs::GeneratePetitionLetterJob.new(@petition, @filename)
  end

  describe "#perform" do
    it "should generate pdf, upload to s3 and send email to campaigner" do
      # generate pdf
      data = mock
      PetitionLetter.should_receive(:create_pdf).with(@petition, false) { data }
      
      # upload to s3
      file = mock
      HttpUploadFile.should_receive(:new).with(@filename, "application/pdf") { file }
      file.should_receive(:write_data).with(data)
      @petition.should_receive(:update_attribute).with(:petition_letter, file)
      
      # mail campaigner
      mailer = mock
      mailer.should_receive(:deliver)
      CampaignerMailer.stub(:notify_petition_letter_ready_for_download).with(@petition) { mailer }
      
      @job.perform
    end
  end
end
