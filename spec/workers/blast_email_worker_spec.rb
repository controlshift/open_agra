require 'spec_helper'

describe BlueStateDigitalConstituentWorker do
  before(:each) do
    @email = Factory(:petition_blast_email)
  end

  it "should perform the necessary work" do

    mailer_obj = mock()
    mailer_obj.stub(:deliver).and_return(true)

    CampaignerMailer.should_receive(:email_supporters).once.with(@email, ["george@washington.com"], ["1234"]).and_return(mailer_obj)

    BlastEmailWorker.new.perform(@email.id, ["george@washington.com"], ["1234"])
  end

end