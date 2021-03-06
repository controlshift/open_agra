module Jobs
  class PromotePetitionJob
    def promote(petition, action)
      case action
      when :encourage
        PromotePetitionMailer.delay.encourage(petition) if self.class.should_email(petition)
      when :achieved_goal
        PromotePetitionMailer.delay.achieved_signature_goal(petition) if self.class.should_email(petition)
      when :reminder_when_dormant
        schedule_reminder_when_dormant(petition.created_at + 1.week, petition)
        schedule_reminder_when_dormant(petition.created_at + 2.week, petition)
        schedule_reminder_when_dormant(petition.created_at + 3.week, petition)
      when :send_launch_kicker
        schedule_send_launch_kicker(petition.created_at + 1.day, petition)
      end
    end
    
    def self.should_email(petition)
      petition.user && !petition.cancelled? && !petition.suppressed? && !petition.prohibited? && !petition.user.opt_out_site_email?
    end

    def schedule_reminder_when_dormant(run_at, petition)
      self.class.delay_until(run_at).send_reminder_when_dormant(petition)
    end

    def self.send_reminder_when_dormant(petition)
      petition.reload
      if petition.signatures.since(1.week.ago).count == 0 && should_email(petition)
        PromotePetitionMailer.reminder_when_dormant(petition).deliver
      end
    end

    def schedule_send_launch_kicker(run_at, petition)
      self.class.delay_until(run_at).send_launch_kicker(petition)
    end

    def self.send_launch_kicker(petition)
      petition.reload
      PromotePetitionMailer.send_launch_kicker(petition).deliver if petition.user && !petition.launched? && !petition.user.opt_out_site_email?
    end
  end
end