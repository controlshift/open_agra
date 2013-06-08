require 'spec_helper'

describe Notifier::Base do
  subject { Notifier::Base.new }

  describe "#notify_sign_up" do
    let(:user_details) { mock }
    let(:petition) { mock }
    let(:organisation) {mock}

    before(:each) do
      subject.should_receive(:process_sign_up).and_return true
      callbacks = [:ensure_external_petition_present, :ensure_creators_page_present, :ensure_category_pages_present]
      callbacks.each do |cb|
        subject.should_receive(cb).and_return(true)
      end

      subject.notify_sign_up(petition: petition, user_details: user_details, organisation: organisation)
    end

    specify{ subject.user_details.should == user_details }
    specify{ subject.petition.should == petition }
    specify{ subject.organisation.should == organisation }
  end
end