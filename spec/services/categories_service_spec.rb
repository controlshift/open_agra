require 'spec_helper'

describe CategoriesService do
  let(:organisation) { Factory.build(:organisation) }
  let(:category) { Factory.build(:category, organisation: organisation) }
  
  subject { CategoriesService.new }

  it { subject.should respond_to(:save) }
  
  it "should notify external system after save" do
    org_notifier = mock
    delayed_job = mock
    OrgNotifier.stub(:new) { org_notifier }
    org_notifier.should_receive(:delay) { delayed_job }
    delayed_job.should_receive(:notify_category_creation).with(organisation: organisation, category: category)
    delayed_job.should_not_receive(:notify_category_update)
    subject.save(category)
  end

  it "should notify external system after update" do
    org_notifier = mock
    delayed_job = mock
    OrgNotifier.stub(:new) { org_notifier }
    org_notifier.should_receive(:delay) { delayed_job }
    delayed_job.should_receive(:notify_category_update).with(organisation: organisation, category: category)
    delayed_job.should_not_receive(:notify_category_creation)

    subject.update_attributes(category, {name: 'foo'})
  end
end