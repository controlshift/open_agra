require "spec_helper"

describe PetitionFlagMailer do
  describe "#notify_organisation_of_flagged_petition" do
    before :each do
      @organisation = Factory(:organisation)
      @petition = Factory(:petition, organisation: @organisation)
      Factory(:petition_flag, petition: @petition)
      @email = PetitionFlagMailer.notify_organisation_of_flagged_petition(@petition).deliver
    end

    subject { @email }
    specify { ActionMailer::Base.deliveries.should_not be_empty }
    specify { subject.subject.should include("has been flagged") }
    specify { subject.to.should == [@petition.organisation.admin_email] }
    specify { subject.from[0].should == @petition.organisation.admin_email }
    specify { subject.body.should include("has been flagged 1 time") }
    specify { subject.body.should include(petition_url(@petition, host: @organisation.host)) }
  end
end
