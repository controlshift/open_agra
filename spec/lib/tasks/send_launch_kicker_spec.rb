require 'spec_helper'

describe "send_launch_kicker" do
  include_context "rake"

  let(:organisation) { Factory(:organisation) }

  its(:prerequisites) { should include('environment') }

  it "should raise exception if organisation is not specified" do
    lambda { subject.invoke }.should raise_error
  end

  context "with proper environment variables" do
    before :each do
      ENV['ORGANISATION'] = organisation.slug
    end

    it "should send launch kicker email to campaigner" do
      launched_petition = Factory(:petition, organisation: organisation, launched: true)
      unlaunched_petition = Factory(:petition, organisation: organisation, launched: false)
      another_unlaunched_petition = Factory(:petition, organisation: organisation, launched: false)
      launched_petition_from_another_org = Factory(:petition, organisation: Factory(:organisation), launched: true)

      mailer_obj = mock()
      mailer_obj.should_receive(:deliver)
      another_mailer_obj = mock()
      another_mailer_obj.should_receive(:deliver)
      PromotePetitionMailer.should_receive(:send_launch_kicker).once.with(unlaunched_petition).and_return(mailer_obj)
      PromotePetitionMailer.should_receive(:send_launch_kicker).once.with(another_unlaunched_petition).and_return(another_mailer_obj)
      PromotePetitionMailer.should_not_receive(:send_launch_kicker).with(launched_petition)
      PromotePetitionMailer.should_not_receive(:send_launch_kicker).with(launched_petition_from_another_org)
      subject.invoke
    end
  end
end