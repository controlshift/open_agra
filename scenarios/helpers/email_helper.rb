module EmailHelper
  include EmailSpec::Helpers
  include EmailSpec::Matchers

  if defined?(ActionMailer)
    unless [:test, :activerecord, :cache, :file].include?(ActionMailer::Base.delivery_method)
      ActionMailer::Base.register_observer(EmailSpec::TestObserver)
    end
    ActionMailer::Base.perform_deliveries = true
  end


end