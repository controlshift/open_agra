require 'spec_helper'

describe "org:notification:import_people" do
  include_context "rake"
  
  let(:organisation) { Factory(:organisation) }
  let(:notify_url) { Faker::Internet.url }

  its(:prerequisites) { should include("environment") }

  it "should raise exception if organisation is not specified" do
    lambda { subject.invoke }.should raise_error
  end
  
  context "with proper environment variables" do
    before :each do
      ENV['URL'] = notify_url
      ENV['ORGANISATION'] = organisation.slug
      
      @notifier = mock
      OrgNotifier.stub(:new) { @notifier }
    end
    
    it "should notify org for people for the same organisation" do
      petition1 = Factory(:petition, organisation: organisation, user: Factory(:user, organisation: organisation, join_organisation: true))
      sign1_1 = Factory(:signature, petition: petition1, join_organisation: true)

      @notifier.should_receive(:notify_sign_up).with(organisation: organisation, petition: petition1, user_details: petition1.user, role: 'creator')
      @notifier.should_receive(:notify_sign_up).with(organisation: organisation, petition: petition1, user_details: sign1_1, role: 'signer')

      subject.invoke
    end

    it "should not notify org for people who do not want to join" do
      petition = Factory(:petition, organisation: organisation, user: Factory(:user, organisation: organisation, join_organisation: false ))
      Factory(:signature, petition: petition, join_organisation: false)

      @notifier.should_not_receive(:notify_sign_up)

      subject.invoke
    end

    it "should not notify org for people for different organisation" do
      petition = Factory(:petition, user: Factory(:user, join_organisation: true))
      Factory(:signature, petition: petition, join_organisation: true)

      @notifier.should_not_receive(:notify_sign_up)

      subject.invoke
    end
  end
end

describe "org:notification:set_url" do
  include_context "rake"
  
  let(:organisation) { Factory(:organisation) }
  let(:notify_url) { Faker::Internet.url }

  its(:prerequisites) { should include("environment") }

  it "should raise exception if notification url is not specified" do
    lambda { subject.invoke }.should raise_error
  end
  
  context "with proper environment variables" do
    before :each do
      ENV['URL'] = notify_url
      ENV['ORGANISATION'] = organisation.slug
    end
    
    it "should update organisation notification url" do
      subject.invoke
      
      organisation.reload
      organisation.notification_url.should == notify_url
    end
  end
end

describe "org:notification:setup" do
  include_context "rake"

  its(:prerequisites) { should include("import_people") }
  its(:prerequisites) { should include("set_url") }
end