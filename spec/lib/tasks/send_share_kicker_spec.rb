require 'spec_helper'

describe "send_share_kicker" do
  include_context "rake"

  let(:organisation) { Factory(:organisation) }

  its(:prerequisites) { should include("environment") }

  it "should raise exception if organisation is not specified" do
    lambda { subject.invoke }.should raise_error
  end

  context "with proper environment variables" do
    before :each do
      ENV['ORGANISATION'] = organisation.slug
    end

    it "should send share kicker email to campaigner" do
      petition_with_one_signature = Factory(:petition, organisation: organisation)
      Factory(:signature, petition: petition_with_one_signature)

      another_petition_with_one_signature = Factory(:petition, organisation: organisation)
      Factory(:signature, petition: another_petition_with_one_signature)

      petition_with_two_signatures =  Factory(:petition, organisation: organisation)
      Factory(:signature, petition: petition_with_two_signatures)
      Factory(:signature, petition: petition_with_two_signatures)

      petition_from_another_org_with_one_signature = Factory(:petition, organisation: Factory(:organisation))
      Factory(:signature, petition: petition_from_another_org_with_one_signature)

      mailer_obj = mock()
      mailer_obj.should_receive(:deliver)
      another_mailer_obj = mock()
      another_mailer_obj.should_receive(:deliver)
      CampaignerMailer.should_receive(:send_share_kicker).once.with(petition_with_one_signature).and_return(mailer_obj)
      CampaignerMailer.should_receive(:send_share_kicker).once.with(another_petition_with_one_signature).and_return(another_mailer_obj)
      CampaignerMailer.should_not_receive(:send_share_kicker).with(petition_with_two_signatures)
      CampaignerMailer.should_not_receive(:send_share_kicker).with(petition_from_another_org_with_one_signature)
      subject.invoke
    end
  end
end