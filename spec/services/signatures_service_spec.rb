require 'spec_helper'

describe SignaturesService do
  include Shoulda::Matchers::ActionMailer

  subject{ SignaturesService.new }

  it "should respond to save" do
    subject.should respond_to(:save)
  end

  context "where there should be callbacks after create" do
    before(:each) do
      @signature = mock()
      @organisation = Factory(:organisation, :notification_url => 'foo')
      @petition = Factory(:petition, organisation: @organisation )
      @signature.stub(:new_record?).and_return(true)
      @signature.stub(:petition).and_return(@petition)
      @signature.stub(:save).and_return(true)
    end

    it "should trigger service callbacks after create" do
      subject.should_receive(:send_thank_you_and_promotion_emails).and_return(true)
      subject.should_receive(:notify_partner_org)
      subject.should_receive(:increment_petition_signatures_count)
      subject.should_receive(:increment_effort_signatures_count)

      subject.save(@signature)
    end

    it "should schedule notification when user signs" do
      Delayed::Job.count.should == 0
      subject.should_receive(:send_thank_you_and_promotion_emails).and_return(true)
      subject.save(@signature)
      Delayed::Job.count.should == 1
      Delayed::Job.last.handler.should match(/notify_sign_up/i)
    end
  end

  it "should not send promotion emails if send fails" do
    signature = mock()
    signature.stub(:new_record?).and_return(true)
    subject.should_not_receive(:send_thank_you_and_promotion_emails).and_return(true)
    signature.should_receive(:save).and_return(nil)
    subject.save(signature)
  end

  it "should actually send the emails. this is kind of an integration spec." do
    organisation = Factory(:organisation)
    user = Factory(:user, organisation: organisation)
    petition = Factory(:petition, user: user, organisation: organisation)
    signature = Factory(:signature, petition: petition)

    subject.stub(:current_object).and_return(signature)
    subject.send_thank_you_and_promotion_emails

    Delayed::Worker.new.work_off
    should have_sent_email.with_subject(/Thanks/)
    should have_sent_email.from(petition.organisation.contact_email)
    should have_sent_email.with_body(/Thank/)
    should have_sent_email.to(signature.email)
  end

  context "well stubbed service" do
    before(:each) do
      @signature = mock()
      @petition = mock()
      @signatures = mock()
      @petition.stub(:cached_signatures_size).and_return(1)
      @petition.stub(:signatures).and_return(@signatures)
      @signature.stub(:petition).and_return(@petition)
      subject.stub(:current_object).and_return(@signature)
      @djob = mock()
      SignatureMailer.stub(:delay).and_return(@djob)
    end

    it "should send a delayed thank you" do
      @djob.should_receive(:thank_signer).with(@signature)
      subject.send_thank_you_and_promotion_emails
    end

    context "stub thank you" do
      before(:each) do
        @djob.stub(:thank_signer)
      end

      it "should send an encouragement, once the target is reached" do
        @djob.stub(:thank_signer)
        @petition.stub(:cached_signatures_size).and_return(SignaturesService::ENCOURAGEMENT_TARGET)
        ppj = mock('ppj')
        Jobs::PromotePetitionJob.stub(:new).and_return(ppj)
        ppj.should_receive(:promote).with(@petition, :encourage)
        subject.send_thank_you_and_promotion_emails
      end

      it "should send an achievement, once the target is reached" do
        @petition.stub(:cached_signatures_size).and_return(SignaturesService::ACHIEVEMENT_TARGET)
        ppj = mock('ppj')
        Jobs::PromotePetitionJob.stub(:new).and_return(ppj)
        ppj.should_receive(:promote).with(@petition, :achieved_goal)
        subject.send_thank_you_and_promotion_emails
      end

      [SignaturesService::ACHIEVEMENT_TARGET+1, SignaturesService::ACHIEVEMENT_TARGET-1].each do | count |
        it "should not send an achievement or encouragement for other values" do
          @petition.stub(:cached_signatures_size).and_return(count)
          ppj = mock('ppj')
          Jobs::PromotePetitionJob.stub(:new).and_return(ppj)
          ppj.should_not_receive(:promote).with(@petition, :encourage)
          ppj.should_not_receive(:promote).with(@petition, :achievement_goal)
          subject.send_thank_you_and_promotion_emails
        end
      end
    end
  end

  describe "signature counters" do
    after(:each) do
      Rails.cache.clear
    end

    context "a petition and a signature" do
      before(:each) do
        @organisation = Factory(:organisation)
        @petition = Factory(:petition, organisation: @organisation)
        @signature = Factory(:signature, petition: @petition)
        subject.stub(:current_object).and_return(@signature)
      end

      describe "the petition counter" do
        it "should increment" do
          subject.send(:increment_petition_signatures_count)
          Rails.cache.read(@petition.signatures_count_key).should == 1
          subject.send(:increment_petition_signatures_count)
          Rails.cache.read(@petition.signatures_count_key).should == 2
          @petition.cached_signatures_size.should == 2
        end

        it "should increment/decrement" do
          subject.send(:decrement_petition_signatures_count)
          Rails.cache.read(@petition.signatures_count_key).should == 1
          subject.send(:decrement_petition_signatures_count)
          Rails.cache.read(@petition.signatures_count_key).should == 0
          @petition.cached_signatures_size.should == 0
        end
      end

      describe "the organisation sig counter" do
        it "should increment" do
          subject.send(:increment_organisation_signatures_count)
          Rails.cache.read(@organisation.signatures_count_key).should == 1
          subject.send(:increment_organisation_signatures_count)
          Rails.cache.read(@organisation.signatures_count_key).should == 2
          @organisation.cached_signatures_size.should == 2
        end

        it "should increment/decrement" do
          subject.send(:decrement_organisation_signatures_count)
          Rails.cache.read(@organisation.signatures_count_key).should == 1
          subject.send(:decrement_organisation_signatures_count)
          Rails.cache.read(@organisation.signatures_count_key).should == 0
          @organisation.cached_signatures_size.should == 0
        end
      end
    end

    context "petition under an effort and a signature" do
      describe "the effort signature counter" do
        before(:each) do
          @organisation = Factory(:organisation)
          @effort = FactoryGirl.create(:effort)
          @petition = FactoryGirl.create(:petition, organisation: @organisation, effort: @effort)
          @signature = FactoryGirl.create(:signature, petition: @petition)
          subject.stub(:current_object).and_return(@signature)
        end

        it "should increment" do
          subject.send(:increment_effort_signatures_count)
          Rails.cache.read(@effort.signatures_count_key).should == 1
          subject.send(:increment_effort_signatures_count)
          Rails.cache.read(@effort.signatures_count_key).should == 2
          @effort.cached_signatures_size.should == 2
        end

        it "should take other petitions in the effort into account" do
          @effort.stub(:signatures_size).and_return(99)
          subject.send(:increment_effort_signatures_count)
          Rails.cache.read(@effort.signatures_count_key).should == 99
          subject.send(:increment_effort_signatures_count)
          Rails.cache.read(@effort.signatures_count_key).should == 100
          @effort.cached_signatures_size.should == 100
        end

        it "should increment/decrement" do
          subject.send(:decrement_effort_signatures_count)
          Rails.cache.read(@effort.signatures_count_key).should == 1
          subject.send(:decrement_effort_signatures_count)
          Rails.cache.read(@effort.signatures_count_key).should == 0
          @effort.cached_signatures_size.should == 0
        end
      end
    end
  end

  describe "group subscriptions and members" do
    context "with a group" do
      before(:each) do
        @organisation = Factory(:organisation)
        @group = Factory(:group, organisation: @organisation)

        @petition = Factory(:petition, organisation: @organisation, group: @group)
      end

      it "should create a group subscription on signature creation" do
        signature = Factory.build(:signature, petition: @petition, join_organisation: true)
        SignaturesService.new.save(signature)
        signature.member.email.should == signature.email
        signature.member.group_subscriptions.collect{| gs | gs.group }.should include(@group)
        @group.subscriptions.collect{|gs| gs.member}.should include(signature.member)
      end
    end

    it "should not subscribe if join_organisation is false" do
      group = Factory.build(:group)
      petition = Factory.build(:petition, group: group)
      signature = Factory.build(:signature, join_organisation: false, petition: petition)
      subject.stub(:current_object).and_return(signature)
      GroupSubscription.should_not_receive(:subscribe!)
      subject.send(:create_group_subscription)
    end
  end
end
