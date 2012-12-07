require 'spec_helper'

describe ModerationMailer do
  describe "notify admin of new petition" do
    before :each do
      @organisation = Factory(:organisation)
      @petition = Factory(:petition, organisation: @organisation)
      @email = ModerationMailer.notify_admin_of_new_petition(@petition).deliver
    end

    subject { @email }
    specify { ActionMailer::Base.deliveries.should_not be_empty }
    specify { subject.subject.should include("needs to be moderated") }
    specify { subject.to.should == [@organisation.admin_email] }
    specify { subject.from.should == [@organisation.admin_email] }
    specify { subject.body.should include("needs to be moderated") }
  end
  
  describe "notify admin of edited petition" do
    before :each do
      @organisation = Factory(:organisation)
      @petition = Factory(:petition, organisation: @organisation)
      @email = ModerationMailer.notify_admin_of_edited_petition(@petition).deliver
    end

    subject { @email }
    specify { ActionMailer::Base.deliveries.should_not be_empty }
    specify { subject.subject.should include("needs to be moderated") }
    specify { subject.to.should == [@organisation.admin_email] }
    specify { subject.from.should == [@organisation.admin_email] }
    specify { subject.body.should include("needs to be moderated") }
  end

  context "for petition blast email" do
    describe "notify campaigner for approved blast email" do
      before :each do
        @organisation = Factory(:organisation)
        @petition = Factory(:petition, organisation: @organisation)
        @blast_email = Factory(:petition_blast_email, petition: @petition, organisation: @organisation)
        @email = ModerationMailer.notify_campaigner_of_approval(@blast_email).deliver
      end

      subject { @email }
      specify { ActionMailer::Base.deliveries.should_not be_empty }
      specify { subject.subject.should include("has been approved") }
      specify { subject.to.should == [@blast_email.from_address] }
      specify { subject.from.should == [@petition.organisation.contact_email] }
      specify { subject.body.should include("has been approved") }
    end

    describe "notify campaigner for rejected blast email" do
      before :each do
        @organisation = Factory(:organisation)
        @petition = Factory(:petition, organisation: @organisation)
        @blast_email = Factory(:petition_blast_email, petition: @petition, organisation: @organisation)
        @email = ModerationMailer.notify_campaigner_of_rejection(@blast_email).deliver
      end

      subject { @email }
      specify { ActionMailer::Base.deliveries.should_not be_empty }
      specify { subject.subject.should include("about your email") }
      specify { subject.to.should == [@blast_email.from_address] }
      specify { subject.from.should == [@petition.organisation.contact_email] }
      specify { subject.body.should include("A member of the team") }
    end

    describe "notify org admin for new blast email" do
      before :each do
        @organisation = Factory(:organisation)
        @petition = Factory(:petition, organisation: @organisation)
        @blast_email = Factory(:petition_blast_email, petition: @petition, organisation: @organisation)
        @email = ModerationMailer.notify_admin_of_new_blast_email(@blast_email).deliver
      end

      subject { @email }
      specify { ActionMailer::Base.deliveries.should_not be_empty }
      specify { subject.subject.should include("An email needs to be moderated") }
      specify { subject.to.should == [@petition.organisation.admin_email] }
      specify { subject.from.should == [@petition.organisation.admin_email] }
      specify { subject.body.should include("needs to be moderated") }
      specify { subject.body.should include org_email_url(@blast_email, host: @organisation.host) }
    end
  end

  context "for group blast email" do
    describe "notify group admin for approved blast email" do
      before :each do
        @organisation = create(:organisation)
        @group = create(:group, organisation: @organisation)
        @blast_email = create(:group_blast_email, group: @group, organisation: @organisation)
        @email = ModerationMailer.notify_campaigner_of_approval(@blast_email).deliver
      end

      subject { @email }
      specify { ActionMailer::Base.deliveries.should_not be_empty }
      specify { subject.subject.should include("has been approved") }
      specify { subject.to.should == [@blast_email.from_address] }
      specify { subject.from.should == [@group.organisation.contact_email] }
      specify { subject.body.should include("has been approved") }
    end

    describe "notify campaigner for rejected blast email" do
      before :each do
        @organisation = create(:organisation)
        @group= create(:group, organisation: @organisation)
        @blast_email = create(:group_blast_email, group: @group, organisation: @organisation)
        @email = ModerationMailer.notify_campaigner_of_rejection(@blast_email).deliver
      end

      subject { @email }
      specify { ActionMailer::Base.deliveries.should_not be_empty }
      specify { subject.subject.should include("about your email") }
      specify { subject.to.should == [@blast_email.from_address] }
      specify { subject.from.should == [@group.organisation.contact_email] }
      specify { subject.body.should include("A member of the team") }
    end

    describe "notify org admin for new blast email" do
      before :each do
        @organisation = create(:organisation)
        @group= create(:group, organisation: @organisation)
        @blast_email = create(:group_blast_email, group: @group, organisation: @organisation)
        @email = ModerationMailer.notify_admin_of_new_blast_email(@blast_email).deliver
      end

      subject { @email }
      specify { ActionMailer::Base.deliveries.should_not be_empty }
      specify { subject.subject.should include("An email needs to be moderated") }
      specify { subject.to.should == [@group.organisation.admin_email] }
      specify { subject.from.should == [@group.organisation.admin_email] }
      specify { subject.body.should include("needs to be moderated") }
      specify { subject.body.should include org_email_url(@blast_email, host: @organisation.host) }
    end
  end

end