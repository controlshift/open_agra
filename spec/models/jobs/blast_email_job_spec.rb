require 'spec_helper'

describe Jobs::BlastEmailJob do
  before(:each) do
    @campaigner = Factory(:user)
    @petition = Factory(:petition, user: @campaigner)
    @email = Factory(:petition_blast_email, petition: @petition)
    @job = Jobs::BlastEmailJob.new()
  end

  describe "#perform" do
    it "should perform sending petition blast email" do
      Factory(:signature, petition: @petition, join_organisation: true)
      signatures = @petition.signatures.subscribed
      BlastEmailWorker.should_receive(:perform_async).once.with(@email.id, signatures.map(&:email), signatures.map(&:token)).and_return(true)

      @job.perform @email
    end

    it "should perform sending group blast email" do

      group = create(:group)
      petition = create(:petition, group: group)
      email = create(:group_blast_email, group: group)
      signature = create(:signature, petition: petition, join_organisation: true)
      member = signature.member
      subscription = GroupSubscription.create(member: member, group: group)

      job = Jobs::BlastEmailJob.new()

      BlastEmailWorker.should_receive(:perform_async).once.with(email.id, [subscription].map(&:email), [subscription].map(&:token)).and_return(true)

      job.perform email
    end

    it "should slice and send blast email in batches" do
      3.times { Factory(:signature, petition: @petition, join_organisation: true) }

      signatures = @petition.signatures.subscribed.order('signatures.id ASC')

      @job.stub(:email_batch_size).and_return(2)

      BlastEmailWorker.should_receive(:perform_async).once.ordered.with(@email.id, signatures[0,2].map(&:email), signatures[0,2].map(&:token))
      BlastEmailWorker.should_receive(:perform_async).once.ordered.with(@email.id, [signatures.last].map(&:email), [signatures.last].map(&:token))

      @job.perform @email
    end
    
    it "should notify organisation when error occurs during the sending" do
      Factory(:signature, petition: @petition, join_organisation: true)
      signatures = @petition.signatures.subscribed

      BlastEmailWorker.should_receive(:perform_async).once.with(@email.id, signatures.map(&:email), signatures.map(&:token)).and_raise(Exception.new)
      ExceptionNotifier::Notifier.should_receive(:background_exception_notification)

      @job.perform @email
    end
  end
end
