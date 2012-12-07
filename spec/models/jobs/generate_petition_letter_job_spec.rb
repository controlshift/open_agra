require 'spec_helper'

describe Jobs::GeneratePetitionLetterJob do
  before(:each) do
    @petition = mock()
    @user = mock()
    @filename = "test.pdf"
  end

  describe "#perform" do
    it "should generate pdf, upload to s3 and send email to campaigner" do
      # generate pdf
      data = mock
      letter = mock
      @petition.stub(:cached_signatures_size).and_return(10)
      Documents::PetitionLetter.should_receive(:new).with(petition: @petition) { letter }
      letter.should_receive(:render).and_return(data)

      # upload to s3
      file = mock
      HttpUploadFile.should_receive(:new).with(@filename, "application/pdf") { file }
      file.should_receive(:write_data).with(data)
      @petition.should_receive(:update_attribute).with(:petition_letter, file)
      
      # mail campaigner
      mailer = mock
      mailer.should_receive(:deliver)
      CampaignerMailer.stub(:notify_petition_letter_ready_for_download).with(@petition, @user) { mailer }

      @job = Jobs::GeneratePetitionLetterJob.new(@petition, @filename, @user)
      @job.perform
    end

    it "should generate a zipped collection of PDFs for large signature counts" do
      @petition = Factory.create(:petition)
      Factory.create(:signature, petition: @petition)
      @petition.reload
      @petition.stub(:cached_signatures_size).and_return(100000)

      # upload to s3
      file = HttpUploadFile.new("#{@petition.slug}.zip", "application/zip")
      HttpUploadFile.should_receive(:new).with("#{@petition.slug}.zip", "application/zip") { file }
      @petition.should_receive(:update_attribute).with(:petition_letter, file)

      # mail campaigner
      mailer = mock
      mailer.should_receive(:deliver)
      CampaignerMailer.stub(:notify_petition_letter_ready_for_download).with(@petition, @user) { mailer }
      @job = Jobs::GeneratePetitionLetterJob.new(@petition, @filename, @user)
      @job.perform
      (file.size > 0).should be_true
    end
  end
end
