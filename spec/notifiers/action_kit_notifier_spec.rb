require 'spec_helper'

describe ActionKitNotifier do
  let(:user) { Factory.stub(:user) }
  let(:petition) { Factory.stub(:petition) }
  let(:role) { 'creator' }
  
  before :each do
    @host = 'localhost'
    @username= 'username'
    @password = '12345'
    @notifier = ActionKitNotifier.new(@host, @username, @password)
  end
  
  describe "#notify_sign_up" do
    it "should not notify if host is blank" do
      RestClient.should_not_receive(:post)
      ActionKitNotifier.new(nil, 'username', 'password').notify_sign_up(user_details: user, role: role).should be_false
    end
    
    it "should not notify if username is blank" do
      RestClient.should_not_receive(:post)
      ActionKitNotifier.new('host', nil, 'password').notify_sign_up(user_details: user, role: role).should be_false
    end
    
    it "should not notify if password is blank" do
      RestClient.should_not_receive(:post)
      ActionKitNotifier.new('host', 'username', nil).notify_sign_up(user_details: user, role: role).should be_false
    end
    
    it 'should connect action kit api and save the user model' do
      petition.stub(:categories) { [OpenStruct.new(slug: 'cat1')] }
      resource_uri = "https://username:12345@localhost/rest/v1/action/"
      data = {
        page: 'page_petition',
        first_name: user.first_name,
        last_name: user.last_name, 
        email: user.email, 
        zip: user.postcode,
        created_at: user.created_at,
        country: 'Australia',
        action_categories: ['cat1']
      }
      
      RestClient.should_receive(:post).with(resource_uri, data.to_json, content_type: :json, accept: :json)

      @notifier.notify_sign_up(user_details: user, role: role, petition: petition, organisation: Factory.build(:organisation, action_kit_country: 'Australia', action_kit_signature_page: 'page_signature', action_kit_petition_page: 'page_petition'))
    end

    it "should propagate raised exceptions" do
      petition.stub(:categories) { [OpenStruct.new(slug: 'cat1')] }
      resource_uri = "https://username:12345@localhost/rest/v1/action/"
      data = {
        page: 'page_petition',
        first_name: user.first_name,
        last_name: user.last_name,
        email: user.email,
        zip: user.postcode,
        created_at: user.created_at,
        country: 'Australia',
        action_categories: ['cat1']
      }

      RestClient.should_receive(:post).with(resource_uri, data.to_json, content_type: :json, accept: :json).and_raise(RestClient::Exception)
      lambda { @notifier.notify_sign_up(user_details: user, role: role, petition: petition, organisation: Factory.build(:organisation, action_kit_country: 'Australia', action_kit_signature_page: 'page_signature', action_kit_petition_page: 'page_petition')) }.should raise_error
    end

    context '#page_for' do
      let(:organisation) { Factory.build(:organisation, action_kit_signature_page: 'page_signature', action_kit_petition_page: 'page_petition')}
      specify { @notifier.send(:page_for, 'creator', organisation).should == 'page_petition' }
      specify { @notifier.send(:page_for, 'signer', organisation).should == 'page_signature' }
      specify { -> { @notifier.send(:page_for, 'non-existing role') }.should raise_error }
    end
  end
end