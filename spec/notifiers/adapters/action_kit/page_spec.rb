require 'spec_helper'

describe Adapters::ActionKit::Action do
  let(:petition) { Factory(:petition, organisation: organisation, external_id: '123')}
  let(:organisation) { Factory(:organisation, action_kit_tag_id: '23') }

  subject { Adapters::ActionKit::Page.new(petition: petition, organisation: organisation) }

  let(:output) { {:name=>"controlshift-#{petition.slug}", :title=>"ControlShift: #{petition.title}", :tags=>["/rest/v1/tag/23/"]} }

  it "should call to hash" do
    subject.to_hash.should == output
  end


  context "an organisation with custom fields" do
    let(:organisation) { Factory(:organisation, action_kit_country: 'US', slug: 'fake', action_kit_tag_id: '23') }

    it "should format the data" do
      subject.to_hash.should == output.merge({list: '10'})
    end

    it "should call the fake page fields class" do
      Adapters::ActionKit::PageFields::Fake.should_receive(:custom_fields).with(petition).and_return({})
      subject.to_hash
    end
  end
end