require 'spec_helper'

describe CategoriesService do
  let(:organisation) { Factory.build(:organisation) }
  let(:category) { Factory.build(:category, organisation: organisation) }
  
  subject { CategoriesService.new }

  it { subject.should respond_to(:save) }
  
  it "should notify external system after save" do
    NotifyCategoryCreationWorker.should_receive(:perform_async)
    subject.save(category)
  end

  it "should notify external system after update" do
    NotifyCategoryUpdateWorker.should_receive(:perform_async)
    subject.update_attributes(category, {name: 'foo'})
  end
end