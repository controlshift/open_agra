require 'spec_helper'

describe NotifyWorker do
  
  describe "#notify" do
    it "should not notify if underlying notifier doesn't support" do
      notifier = mock
      organisation = Factory.stub(:organisation, notifiers: "test")
      params = { organisation: organisation }
      
      NotifyWorker.any_instance.stub(:notifier_for_name).with("test", organisation) { notifier }
      notifier.stub(:respond_to?).with(:some_notifying_method) { false }
      notifier.should_not_receive(:send)

      NotifyWorker.new.notify(:some_notifying_method, params)
    end
    
    it "should notify if underlying notifier support" do
      notifier = mock
      organisation = Factory.stub(:organisation, notifiers: "test")
      params = { organisation: organisation }
      
      NotifyWorker.any_instance.stub(:notifier_for_name).with("test", organisation) { notifier }
      notifier.stub(:respond_to?).with(:some_notifying_method) { true }
      notifier.should_receive(:send).with(:some_notifying_method, params)
      
      NotifyWorker.new.notify(:some_notifying_method, params)
    end
    
    it "should notify and log exception when failed" do
      notifier = mock
      organisation = Factory.stub(:organisation, notifiers: "test")
      params = { organisation: organisation }
      error = Exception.new
      
      NotifyWorker.any_instance.stub(:notifier_for_name).with("test", organisation) { notifier }
      notifier.stub(:respond_to?).with(:some_notifying_method) { true }
      notifier.should_receive(:send).with(:some_notifying_method, params).and_raise(error)
      ExceptionNotifier::Notifier.should_receive(:background_exception_notification).with(error)
      
      NotifyWorker.new.notify(:some_notifying_method, params)
    end
    
    it "should notify Tijuana" do
      organisation = Factory.stub(:organisation, notifiers: "Tijuana")
      params = { organisation: organisation }

      tijuana_notifier = tijuana_notifier_mock
      tijuana_notifier.should_receive(:notify).with(params)

      NotifyWorker.new.notify(:notify, params)
    end

    it "should notify BlueStateDigital" do
      organisation = Factory.stub(:organisation, notifiers: "BlueStateDigital", bsd_host: "host.com", bsd_api_id: "id", bsd_api_secret: "secret")
      params = { organisation: organisation }

      bsd_notifier = bsd_notifier_mock(organisation)
      bsd_notifier.should_receive(:notify).with(params)

      NotifyWorker.new.notify(:notify, params)
    end

    it "should notify ActionKit" do
      organisation = Factory.stub(:organisation, notifiers: "ActionKit", action_kit_host: "host.com", action_kit_username: "id", action_kit_password: "secret")
      params = { organisation: organisation }

      action_kit_notifier = action_kit_notifier_mock(organisation)
      action_kit_notifier.should_receive(:notify).with(params)

      NotifyWorker.new.notify(:notify, params)
    end

    it "should notify multiple notifiers" do
      organisation = Factory.stub(:organisation, notifiers: "Tijuana, BlueStateDigital, ActionKit",
                                        bsd_host: "host.com", bsd_api_id: "id", bsd_api_secret: "secret",
                                        action_kit_host: "host.com", action_kit_username: "id", action_kit_password: "secret")
      params = { organisation: organisation }

      tijuana_notifier = tijuana_notifier_mock
      tijuana_notifier.should_receive(:notify).with(params)
      bsd_notifier = bsd_notifier_mock(organisation)
      bsd_notifier.should_receive(:notify).with(params)
      action_kit_notifier = action_kit_notifier_mock(organisation)
      action_kit_notifier.should_receive(:notify).with(params)

      NotifyWorker.new.notify(:notify, params)
    end
  end
  
  private

  def tijuana_notifier_mock
    tijuana_notifier = mock
    TijuanaNotifier.stub(:new) { tijuana_notifier }
    tijuana_notifier
  end
  
  def bsd_notifier_mock(organisation)
    bsd_notifier = mock
    BlueStateDigitalNotifier.stub(:new).with(organisation.bsd_host, organisation.bsd_api_id, organisation.bsd_api_secret) { bsd_notifier }
    bsd_notifier
  end

  def action_kit_notifier_mock(organisation)
    action_kit_notifier = mock
    ActionKitNotifier.stub(:new).with(organisation.action_kit_host, organisation.action_kit_username, organisation.action_kit_password) { action_kit_notifier }
    action_kit_notifier
  end
end
