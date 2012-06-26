require 'spec_helper'

describe TijuanaNotifier do
  let(:response) { mock }
  
  before :each do
    @organisation = Factory.stub(:organisation)
    @petition = Factory.stub(:petition, organisation: @organisation)
    @user_details = Factory.stub(:user, organisation: @organisation)
    @role = "creator"
  end
  
  describe "#notify_sign_up" do
    it "should not post request if organisation has no notification url" do
      @organisation.notification_url = nil
      @user_details.join_organisation = true
      
      Net::HTTP.should_not_receive(:post_form)
      
      TijuanaNotifier.new.notify_sign_up(petition: @petition, user_details: @user_details, role: @role).should be_false
    end
    
    it "should not post request if user do not join organisation" do
      @organisation.notification_url = "url"
      @user_details.join_organisation = false
      
      Net::HTTP.should_not_receive(:post_form)
      
      TijuanaNotifier.new.notify_sign_up(petition: @petition, user_details: @user_details, role: @role).should be_false
    end
    
    it "should post to the supplied URL with the correct JSON" do
      @organisation.notification_url = "url"
      @user_details.join_organisation = true
      @json = { slug: @petition.slug, first_name: @user_details.first_name, last_name: @user_details.last_name,
        email: @user_details.email, postcode: @user_details.postcode, phone_number: @user_details.phone_number, role: @role}.to_json        
      response.stub(:value)

      Net::HTTP.should_receive(:post_form).with(URI.parse(@petition.organisation.notification_url), data: @json) { response }
      
      TijuanaNotifier.new.notify_sign_up(petition: @petition, user_details: @user_details, role: @role).should be_true
    end

    it "should fail when the response is not 2XX and notify admin with the exception" do
      @organisation.notification_url = "url"
      @user_details.join_organisation = true
      error = Exception.new
      response.stub(:value).and_raise(error)

      Net::HTTP.should_receive(:post_form) { response }
      
      -> { TijuanaNotifier.new.notify_sign_up(petition: @petition, user_details: @user_details, role: @role) }.should raise_error
    end
  end
end
