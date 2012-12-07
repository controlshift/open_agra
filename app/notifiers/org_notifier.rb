class OrgNotifier

  def notify_sign_up(params = {})
    notify(:notify_sign_up, params)
  end
  
  def notify_category_creation(params = {})
    notify(:notify_category_creation, params)
  end

  def notify_category_update(params = {})
    notify(:notify_category_update, params)
  end
  
  def notify(method, params = {})
    organisation = params[:organisation]
    return if organisation.notifiers.blank?
  
    notifiers = organisation.notifiers.split(',')
    notifiers.each do |name|
      begin
        notifier = notifier_for_name(name, organisation)
        if notifier && notifier.respond_to?(method)
          notifier.send(method, params)
        end
      rescue Exception => exception
        Rails.logger.warn exception.inspect
        Rails.logger.warn exception.backtrace

        ExceptionNotifier::Notifier.background_exception_notification(exception)
      end
    end
  end
  
  private
  
  def notifier_for_name(name, organisation)
    notifier = nil
    unless name.blank?
      case name.strip.downcase
      when 'tijuana'
        notifier = TijuanaNotifier.new
      when 'bluestatedigital'
        notifier = BlueStateDigitalNotifier.new(organisation.bsd_host, organisation.bsd_api_id, organisation.bsd_api_secret)
      when 'actionkit'
        notifier = ActionKitNotifier.new(organisation.action_kit_host, organisation.action_kit_username, organisation.action_kit_password)
      when 'salesforce'
        notifier = SalesforceNotifier.new
      end
    end
    notifier
  end
end
