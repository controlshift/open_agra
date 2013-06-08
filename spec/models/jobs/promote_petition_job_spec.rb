require 'spec_helper'

describe Jobs::PromotePetitionJob do
  let(:petition) { Factory.stub(:petition) }
  let(:cancelled_petition) { Factory.stub(:cancelled_petition) }
  let(:suppressed_petition) { Factory.stub(:petition, admin_status: :suppressed) }
  let(:delayed_job) { mock }
  
  describe "encourage" do
    before :each do
      PromotePetitionMailer.stub(:delay) { delayed_job }
    end
    
    it "should send delayed email" do
      delayed_job.should_receive(:encourage).with(petition)
      subject.promote(petition, :encourage)
    end

    it "should not send delayed email if cancenlled" do
      delayed_job.should_not_receive(:encourage)
      subject.promote(cancelled_petition, :encourage)
    end
    
    it "should not send delayed email if suppressed" do
      delayed_job.should_not_receive(:encourage)
      subject.promote(suppressed_petition, :encourage)
    end
    
    it "should not send delayed email if user opted out" do
      cancelled_petition.user.opt_out_site_email = true
      delayed_job.should_not_receive(:encourage)
      subject.promote(cancelled_petition, :encourage)
    end
  end
  
  describe "achieved_goal" do
    before :each do
      PromotePetitionMailer.stub(:delay) { delayed_job }
    end
    
    it "should send delayed email" do
      delayed_job.should_receive(:achieved_signature_goal).with(petition)
      subject.promote(petition, :achieved_goal)
    end

    it "should not send delayed email if cancenlled" do
      delayed_job.should_not_receive(:achieved_signature_goal)
      subject.promote(cancelled_petition, :achieved_goal)
    end
    
    it "should not send delayed email if suppressed" do
      delayed_job.should_not_receive(:achieved_signature_goal)
      subject.promote(suppressed_petition, :achieved_goal)
    end
    
    it "should not send delayed email if user opted out" do
      cancelled_petition.user.opt_out_site_email = true
      delayed_job.should_not_receive(:achieved_signature_goal)
      subject.promote(cancelled_petition, :achieved_goal)
    end
  end
  
  describe "reminder_when_dormant" do
    it "should schedule delay email for coming weeks" do
      subject.class.should_receive(:delay_until).with(petition.created_at + 1.week) { delayed_job }
      subject.class.should_receive(:delay_until).with(petition.created_at + 2.week) { delayed_job }
      subject.class.should_receive(:delay_until).with(petition.created_at + 3.week) { delayed_job }
      delayed_job.should_receive(:send_reminder_when_dormant).with(petition).exactly(3).times
      subject.promote(petition, :reminder_when_dormant)
    end
    
    context "without new signatures" do
      before :each do
        Timecop.freeze(Time.now)

        signatures = mock
        petition.should_receive(:reload)
        petition.should_receive(:signatures) { signatures }
        signatures.should_receive(:since).with(1.week.ago) { mock(count: 0) }
      end
      
      after :each do
        Timecop.return
      end
      
      it "should send reminder when dormant email" do
        mailer = mock
        PromotePetitionMailer.should_receive(:reminder_when_dormant).with(petition) { mailer }
        mailer.should_receive(:deliver)

        Jobs::PromotePetitionJob.send_reminder_when_dormant(petition)
      end
      
      it "should not send reminder when dormant email if petition is cancelled" do
        petition.cancelled = true
        PromotePetitionMailer.should_not_receive(:reminder_when_dormant)
        Jobs::PromotePetitionJob.send_reminder_when_dormant(petition)
      end
      
      it "should not send reminder when dormant email if petition is prohibited" do
        petition.stub(:prohibited?) { true }
        PromotePetitionMailer.should_not_receive(:reminder_when_dormant)
        Jobs::PromotePetitionJob.send_reminder_when_dormant(petition)
      end
      
      it "should not send reminder when dormant email if petition is suppressed" do
        petition.stub(:suppressed?) { true }
        PromotePetitionMailer.should_not_receive(:reminder_when_dormant)
        Jobs::PromotePetitionJob.send_reminder_when_dormant(petition)
      end
      
      it "should not send reminder when dormant email if user opted out" do
        petition.user.opt_out_site_email = true
        PromotePetitionMailer.should_not_receive(:reminder_when_dormant)
        Jobs::PromotePetitionJob.send_reminder_when_dormant(petition)
      end
    end
    
    context "with new signatures" do
      before :each do
        Timecop.freeze(Time.now)

        signatures = mock
        petition.should_receive(:reload)
        petition.should_receive(:signatures) { signatures }
        signatures.should_receive(:since).with(1.week.ago) { mock(count: 1) }
      end

      after :each do
        Timecop.return
      end
      
      it "should not send reminder when dormant email" do
        PromotePetitionMailer.should_not_receive(:reminder_when_dormant)
        Jobs::PromotePetitionJob.send_reminder_when_dormant(petition)
      end
    end
  end

  describe "send_launch_kicker" do

    it "should schedule delay email for next day" do
      delayed_job.should_receive(:send_launch_kicker).with(petition)
      subject.class.should_receive(:delay_until).with(petition.created_at + 1.day) { delayed_job }

      subject.promote(petition, :send_launch_kicker)
    end

    it "should send reminder one day later if the created petition is not launched" do
      petition.should_receive(:reload)
      petition.should_receive(:launched?) { false }
      mailer = mock
      mailer.should_receive(:deliver)
      PromotePetitionMailer.should_receive(:send_launch_kicker).with(petition) { mailer }

      Jobs::PromotePetitionJob.send_launch_kicker(petition)
    end

    it "should not send reminder if petition is already launched" do
      petition.stub(:reload)
      petition.stub(:launched?).and_return true

      PromotePetitionMailer.should_not_receive(:send_launch_kicker)
      Jobs::PromotePetitionJob.send_launch_kicker(petition)
    end

    it "should not send reminder if the user opted out" do
      petition.stub(:reload)
      petition.stub(:launched?).and_return false
      petition.user.opt_out_site_email = true

      PromotePetitionMailer.should_not_receive(:send_launch_kicker)
      Jobs::PromotePetitionJob.send_launch_kicker(petition)
    end
  end

end