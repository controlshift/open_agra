require 'spec_helper'

describe TargetCollection do
  it { should validate_presence_of :name }
  it { should validate_presence_of :organisation }

  context "an object" do
    subject { FactoryGirl.create(:target_collection) }

    it { should validate_uniqueness_of(:name).scoped_to(:organisation_id) }
  end
end
