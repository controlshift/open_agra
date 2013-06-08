require 'spec_helper'

describe Jobs::GeneratePetitionLetterJob do
  describe "#perform" do
    context "with everything stubbed" do
      before(:each) do
        @petition = mock_model(Petition)
        @user = mock_model(User)
        Petition.stub(:find).and_return(@petition)
        User.stub(:find).and_return(@user)
        @filename = "test.pdf"
      end

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

        @job = Jobs::GeneratePetitionLetterJob.new
        @job.perform @petition.id, @filename, @user.id
      end
    end
    context "with a real petition" do
      before(:each) do
        @petition = Factory(:petition)
        @user = mock_model(User)
        Petition.stub(:find).and_return(@petition)
        User.stub(:find).and_return(@user)
        @filename = "test.pdf"
      end

        it "should generate a zipped collection of PDFs for large signature counts" do
        @petition.stub(:cached_signatures_size).and_return(100000)

        # upload to s3
        file = HttpUploadFile.new("#{@petition.slug}.zip", "application/zip")
        HttpUploadFile.should_receive(:new).with("#{@petition.slug}.zip", "application/zip") { file }
        @petition.should_receive(:update_attribute).with(:petition_letter, file)

        # mail campaigner
        mailer = mock
        mailer.should_receive(:deliver)
        CampaignerMailer.stub(:notify_petition_letter_ready_for_download).with(@petition, @user) { mailer }
        @job = Jobs::GeneratePetitionLetterJob.new
        @job.perform(@petition.id, @filename, @user.id)
        (file.size > 0).should be_true
      end
    end
  end
end
